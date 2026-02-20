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
            .heartRate,
            .restingHeartRate,
            .heartRateVariabilitySDNN,
            .stepCount,
            .activeEnergyBurned,
            .basalEnergyBurned,
            .distanceWalkingRunning,
            .bodyMass,
            .bodyFatPercentage,
            .oxygenSaturation,
            .respiratoryRate,
            .vo2Max,
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

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let startDate = formatter.date(from: startDateStr),
              let endDate = formatter.date(from: endDateStr) else {
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

        if let hr = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            allTypes.append(hr)
        }
        if let sc = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            allTypes.append(sc)
        }
        if let sleep = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
            allTypes.append(sleep)
        }

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

    private func setupObserverQuery(for sampleType: HKSampleType) {
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { [weak self] _, completionHandler, error in
            guard error == nil else {
                completionHandler()
                return
            }

            self?.notifyListeners("healthKitDataUpdated", data: [
                "sampleType": sampleType.identifier,
            ])

            completionHandler()
        }
        healthStore.execute(query)
    }
}
