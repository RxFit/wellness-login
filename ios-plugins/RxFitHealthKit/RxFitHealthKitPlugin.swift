import Foundation
import Capacitor
import HealthKit

@objc(RxFitHealthKitPlugin)
public class RxFitHealthKitPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "RxFitHealthKitPlugin"
    public let jsName = "RxFitHealthKit"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "requestAuthorization", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "queryAllSamples", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "enableBackgroundDelivery", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isAvailable", returnType: CAPPluginReturnPromise),
    ]

    private let healthStore = HKHealthStore()
    private let syncManager = HealthKitSyncManager()

    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()

        let quantityTypes: [HKQuantityTypeIdentifier] = [
            // Vitals & cardiovascular
            .heartRate,
            .restingHeartRate,
            .heartRateVariabilitySDNN,
            .oxygenSaturation,
            .respiratoryRate,
            .vo2Max,
            // Body composition
            .bodyMass,
            .bodyFatPercentage,
            .leanBodyMass,
            // Activity & movement
            .stepCount,
            .activeEnergyBurned,
            .basalEnergyBurned,
            .distanceWalkingRunning,
            .appleExerciseTime,
            .appleStandTime,
            .walkingHeartRateAverage,
            .walkingSpeed,
            .walkingStepLength,
            .walkingAsymmetryPercentage,
            .stairAscentSpeed,
            .stairDescentSpeed,
            .sixMinuteWalkTestDistance,
            // Nutrition — macronutrients
            .dietaryEnergyConsumed,
            .dietaryProtein,
            .dietaryCarbohydrates,
            .dietaryFatTotal,
            .dietarySugar,
            .dietaryFiber,
            // Nutrition — micronutrients
            .dietaryCholesterol,
            .dietarySodium,
            .dietaryIron,
            .dietaryPotassium,
            .dietaryCaffeine,
            // Hydration
            .dietaryWater,
        ]

        for identifier in quantityTypes {
            if let type = HKQuantityType.quantityType(forIdentifier: identifier) {
                types.insert(type)
            }
        }

        if let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepType)
        }

        types.insert(HKWorkoutType.workoutType())

        return types
    }

    @objc func isAvailable(_ call: CAPPluginCall) {
        call.resolve(["available": HKHealthStore.isHealthDataAvailable()])
    }

    @objc func requestAuthorization(_ call: CAPPluginCall) {
        guard HKHealthStore.isHealthDataAvailable() else {
            call.resolve(["granted": false, "error": "HealthKit is not available on this device"])
            return
        }

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if let error = error {
                call.resolve(["granted": false, "error": error.localizedDescription])
            } else {
                call.resolve(["granted": success])
            }
        }
    }

    @objc func queryAllSamples(_ call: CAPPluginCall) {
        guard let startDateStr = call.getString("startDate"),
              let endDateStr = call.getString("endDate") else {
            call.reject("startDate and endDate are required")
            return
        }

        guard let startDate = parseISO8601(startDateStr),
              let endDate = parseISO8601(endDateStr) else {
            call.reject("Invalid date format")
            return
        }

        syncManager.queryAllSamples(
            healthStore: healthStore,
            startDate: startDate,
            endDate: endDate
        ) { samples, deviceInfo in
            call.resolve([
                "samples": samples,
                "deviceInfo": deviceInfo,
            ])
        }
    }

    @objc func enableBackgroundDelivery(_ call: CAPPluginCall) {
        var allTypes: [HKSampleType] = []

        let quantityIdentifiers: [HKQuantityTypeIdentifier] = [
            // Vitals & cardiovascular
            .heartRate,
            .restingHeartRate,
            .heartRateVariabilitySDNN,
            .oxygenSaturation,
            .respiratoryRate,
            .vo2Max,
            // Body composition
            .bodyMass,
            .bodyFatPercentage,
            .leanBodyMass,
            // Activity & movement
            .stepCount,
            .activeEnergyBurned,
            .basalEnergyBurned,
            .distanceWalkingRunning,
            .appleExerciseTime,
            .appleStandTime,
            .walkingHeartRateAverage,
            .walkingSpeed,
            .walkingStepLength,
            .walkingAsymmetryPercentage,
            .stairAscentSpeed,
            .stairDescentSpeed,
            .sixMinuteWalkTestDistance,
            // Nutrition — macronutrients
            .dietaryEnergyConsumed,
            .dietaryProtein,
            .dietaryCarbohydrates,
            .dietaryFatTotal,
            .dietarySugar,
            .dietaryFiber,
            // Nutrition — micronutrients
            .dietaryCholesterol,
            .dietarySodium,
            .dietaryIron,
            .dietaryPotassium,
            .dietaryCaffeine,
            // Hydration
            .dietaryWater,
        ]

        for identifier in quantityIdentifiers {
            if let type = HKQuantityType.quantityType(forIdentifier: identifier) {
                allTypes.append(type)
            }
        }

        if let sleep = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
            allTypes.append(sleep)
        }

        allTypes.append(HKWorkoutType.workoutType())

        let group = DispatchGroup()
        var enabledCount = 0
        let lock = NSLock()

        for sampleType in allTypes {
            group.enter()
            healthStore.enableBackgroundDelivery(for: sampleType, frequency: .hourly) { success, error in
                if success {
                    lock.lock()
                    enabledCount += 1
                    lock.unlock()

                    self.setupObserverQuery(for: sampleType)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            call.resolve(["enabled": enabledCount > 0, "count": enabledCount])
        }
    }

    private func parseISO8601(_ string: String) -> Date? {
        let formatterWithFraction = ISO8601DateFormatter()
        formatterWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFraction.date(from: string) {
            return date
        }

        let formatterWithout = ISO8601DateFormatter()
        formatterWithout.formatOptions = [.withInternetDateTime]
        return formatterWithout.date(from: string)
    }

    private func setupObserverQuery(for sampleType: HKSampleType) {
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { [weak self] _, completionHandler, error in
            guard error == nil else {
                completionHandler()
                return
            }

            // Notify JS bridge (works when app is in foreground with active WebView)
            self?.notifyListeners("healthKitDataUpdated", data: [
                "sampleType": sampleType.identifier,
            ])

            // Native fallback: sync directly via HTTP when JS bridge may be unavailable
            self?.performNativeSync()

            completionHandler()
        }
        healthStore.execute(query)
    }

    private func performNativeSync() {
        let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()

        syncManager.queryAllSamples(
            healthStore: healthStore,
            startDate: oneHourAgo,
            endDate: Date()
        ) { samples, deviceInfo in
            guard !samples.isEmpty else { return }

            guard let url = URL(string: "https://app.rxfit.ai/api/healthkit/sync") else { return }

            let body: [String: Any] = [
                "samples": samples,
                "deviceInfo": deviceInfo,
            ]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = 30

            if let cookieURL = URL(string: "https://app.rxfit.ai"),
               let cookies = HTTPCookieStorage.shared.cookies(for: cookieURL) {
                let headers = HTTPCookie.requestHeaderFields(with: cookies)
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }

            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("RxFit: Observer sync failed: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        print("RxFit: Observer sync completed — \(samples.count) samples")
                    } else {
                        print("RxFit: Observer sync returned \(httpResponse.statusCode)")
                    }
                }
            }.resume()
        }
    }
}
