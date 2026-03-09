import Foundation
import HealthKit
import UIKit

class HealthKitSyncManager {
    static let isoFormatter = ISO8601DateFormatter()

    private let unitMapping: [HKQuantityTypeIdentifier: HKUnit] = [
        // Vitals & cardiovascular
        .heartRate: HKUnit.count().unitDivided(by: .minute()),
        .restingHeartRate: HKUnit.count().unitDivided(by: .minute()),
        .heartRateVariabilitySDNN: HKUnit.secondUnit(with: .milli),
        .oxygenSaturation: HKUnit.percent(),
        .respiratoryRate: HKUnit.count().unitDivided(by: .minute()),
        .vo2Max: HKUnit(from: "ml/kg*min"),
        // Body composition
        .bodyMass: HKUnit.gramUnit(with: .kilo),
        .bodyFatPercentage: HKUnit.percent(),
        .leanBodyMass: HKUnit.gramUnit(with: .kilo),
        // Activity & movement
        .stepCount: HKUnit.count(),
        .activeEnergyBurned: HKUnit.kilocalorie(),
        .basalEnergyBurned: HKUnit.kilocalorie(),
        .distanceWalkingRunning: HKUnit.meter(),
        .appleExerciseTime: HKUnit.minute(),
        .appleStandTime: HKUnit.minute(),
        .walkingHeartRateAverage: HKUnit.count().unitDivided(by: .minute()),
        .walkingSpeed: HKUnit.meter().unitDivided(by: .second()),
        .walkingStepLength: HKUnit.meter(),
        .walkingAsymmetryPercentage: HKUnit.percent(),
        .stairAscentSpeed: HKUnit.meter().unitDivided(by: .second()),
        .stairDescentSpeed: HKUnit.meter().unitDivided(by: .second()),
        .sixMinuteWalkTestDistance: HKUnit.meter(),
        // Nutrition — macronutrients
        .dietaryEnergyConsumed: HKUnit.kilocalorie(),
        .dietaryProtein: HKUnit.gram(),
        .dietaryCarbohydrates: HKUnit.gram(),
        .dietaryFatTotal: HKUnit.gram(),
        .dietarySugar: HKUnit.gram(),
        .dietaryFiber: HKUnit.gram(),
        // Nutrition — micronutrients
        .dietaryCholesterol: HKUnit.gramUnit(with: .milli),
        .dietarySodium: HKUnit.gramUnit(with: .milli),
        .dietaryIron: HKUnit.gramUnit(with: .milli),
        .dietaryPotassium: HKUnit.gramUnit(with: .milli),
        .dietaryCaffeine: HKUnit.gramUnit(with: .milli),
        // Hydration
        .dietaryWater: HKUnit.literUnit(with: .milli),
    ]

    private let unitStringMapping: [HKQuantityTypeIdentifier: String] = [
        // Vitals & cardiovascular
        .heartRate: "count/min",
        .restingHeartRate: "count/min",
        .heartRateVariabilitySDNN: "ms",
        .oxygenSaturation: "%",
        .respiratoryRate: "count/min",
        .vo2Max: "ml/kg*min",
        // Body composition
        .bodyMass: "kg",
        .bodyFatPercentage: "%",
        .leanBodyMass: "kg",
        // Activity & movement
        .stepCount: "count",
        .activeEnergyBurned: "kcal",
        .basalEnergyBurned: "kcal",
        .distanceWalkingRunning: "m",
        .appleExerciseTime: "min",
        .appleStandTime: "min",
        .walkingHeartRateAverage: "count/min",
        .walkingSpeed: "m/s",
        .walkingStepLength: "m",
        .walkingAsymmetryPercentage: "%",
        .stairAscentSpeed: "m/s",
        .stairDescentSpeed: "m/s",
        .sixMinuteWalkTestDistance: "m",
        // Nutrition — macronutrients
        .dietaryEnergyConsumed: "kcal",
        .dietaryProtein: "g",
        .dietaryCarbohydrates: "g",
        .dietaryFatTotal: "g",
        .dietarySugar: "g",
        .dietaryFiber: "g",
        // Nutrition — micronutrients
        .dietaryCholesterol: "mg",
        .dietarySodium: "mg",
        .dietaryIron: "mg",
        .dietaryPotassium: "mg",
        .dietaryCaffeine: "mg",
        // Hydration
        .dietaryWater: "mL",
    ]

    private let sampleTypeNames: [HKQuantityTypeIdentifier: String] = [
        // Vitals & cardiovascular
        .heartRate: "heartRate",
        .restingHeartRate: "restingHeartRate",
        .heartRateVariabilitySDNN: "heartRateVariabilitySDNN",
        .oxygenSaturation: "oxygenSaturation",
        .respiratoryRate: "respiratoryRate",
        .vo2Max: "vo2Max",
        // Body composition
        .bodyMass: "bodyMass",
        .bodyFatPercentage: "bodyFatPercentage",
        .leanBodyMass: "leanBodyMass",
        // Activity & movement
        .stepCount: "stepCount",
        .activeEnergyBurned: "activeEnergyBurned",
        .basalEnergyBurned: "basalEnergyBurned",
        .distanceWalkingRunning: "distanceWalkingRunning",
        .appleExerciseTime: "appleExerciseTime",
        .appleStandTime: "appleStandTime",
        .walkingHeartRateAverage: "walkingHeartRateAverage",
        .walkingSpeed: "walkingSpeed",
        .walkingStepLength: "walkingStepLength",
        .walkingAsymmetryPercentage: "walkingAsymmetryPercentage",
        .stairAscentSpeed: "stairAscentSpeed",
        .stairDescentSpeed: "stairDescentSpeed",
        .sixMinuteWalkTestDistance: "sixMinuteWalkTestDistance",
        // Nutrition — macronutrients
        .dietaryEnergyConsumed: "dietaryEnergyConsumed",
        .dietaryProtein: "dietaryProtein",
        .dietaryCarbohydrates: "dietaryCarbohydrates",
        .dietaryFatTotal: "dietaryFatTotal",
        .dietarySugar: "dietarySugar",
        .dietaryFiber: "dietaryFiber",
        // Nutrition — micronutrients
        .dietaryCholesterol: "dietaryCholesterol",
        .dietarySodium: "dietarySodium",
        .dietaryIron: "dietaryIron",
        .dietaryPotassium: "dietaryPotassium",
        .dietaryCaffeine: "dietaryCaffeine",
        // Hydration
        .dietaryWater: "dietaryWater",
    ]

    func queryAllSamples(
        healthStore: HKHealthStore,
        startDate: Date,
        endDate: Date,
        completion: @escaping ([[String: Any]], [String: Any]) -> Void
    ) {
        let group = DispatchGroup()
        var allSamples: [[String: Any]] = []
        let lock = NSLock()

        let quantityTypes: [HKQuantityTypeIdentifier] = [
            // Vitals & cardiovascular
            .heartRate, .restingHeartRate, .heartRateVariabilitySDNN,
            .oxygenSaturation, .respiratoryRate, .vo2Max,
            // Body composition
            .bodyMass, .bodyFatPercentage, .leanBodyMass,
            // Activity & movement
            .stepCount, .activeEnergyBurned, .basalEnergyBurned,
            .distanceWalkingRunning, .appleExerciseTime, .appleStandTime,
            .walkingHeartRateAverage, .walkingSpeed, .walkingStepLength,
            .walkingAsymmetryPercentage, .stairAscentSpeed, .stairDescentSpeed,
            .sixMinuteWalkTestDistance,
            // Nutrition — macronutrients
            .dietaryEnergyConsumed, .dietaryProtein, .dietaryCarbohydrates,
            .dietaryFatTotal, .dietarySugar, .dietaryFiber,
            // Nutrition — micronutrients
            .dietaryCholesterol, .dietarySodium, .dietaryIron,
            .dietaryPotassium, .dietaryCaffeine,
            // Hydration
            .dietaryWater,
        ]

        for identifier in quantityTypes {
            guard let sampleType = HKQuantityType.quantityType(forIdentifier: identifier),
                  let unit = unitMapping[identifier],
                  let unitStr = unitStringMapping[identifier],
                  let typeName = sampleTypeNames[identifier] else { continue }

            group.enter()
            queryQuantitySamples(
                healthStore: healthStore,
                type: sampleType,
                unit: unit,
                unitString: unitStr,
                typeName: typeName,
                startDate: startDate,
                endDate: endDate
            ) { samples in
                lock.lock()
                allSamples.append(contentsOf: samples)
                lock.unlock()
                group.leave()
            }
        }

        group.enter()
        querySleepSamples(
            healthStore: healthStore,
            startDate: startDate,
            endDate: endDate
        ) { samples in
            lock.lock()
            allSamples.append(contentsOf: samples)
            lock.unlock()
            group.leave()
        }

        group.enter()
        queryWorkoutSamples(
            healthStore: healthStore,
            startDate: startDate,
            endDate: endDate
        ) { samples in
            lock.lock()
            allSamples.append(contentsOf: samples)
            lock.unlock()
            group.leave()
        }

        group.notify(queue: .main) {
            let deviceInfo = self.getDeviceInfo()
            completion(allSamples, deviceInfo)
        }
    }

    private func queryQuantitySamples(
        healthStore: HKHealthStore,
        type: HKQuantityType,
        unit: HKUnit,
        unitString: String,
        typeName: String,
        startDate: Date,
        endDate: Date,
        completion: @escaping ([[String: Any]]) -> Void
    ) {
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: true
        )

        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            guard let samples = results as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }

            let formatted = samples.map { sample -> [String: Any] in
                let value = sample.quantity.doubleValue(for: unit)
                return [
                    "sampleType": typeName,
                    "value": value,
                    "valueFloat": String(format: "%.2f", value),
                    "unit": unitString,
                    "startDate": HealthKitSyncManager.isoFormatter.string(from: sample.startDate),
                    "endDate": HealthKitSyncManager.isoFormatter.string(from: sample.endDate),
                    "sourceName": sample.sourceRevision.source.name,
                    "sourceId": sample.sourceRevision.source.bundleIdentifier,
                    "metadata": [:] as [String: Any],
                ]
            }

            completion(formatted)
        }

        healthStore.execute(query)
    }

    private func querySleepSamples(
        healthStore: HKHealthStore,
        startDate: Date,
        endDate: Date,
        completion: @escaping ([[String: Any]]) -> Void
    ) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([])
            return
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: true
        )

        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            guard let samples = results as? [HKCategorySample], error == nil else {
                completion([])
                return
            }

            let formatted = samples.map { sample -> [String: Any] in
                let stage = self.sleepStageString(from: sample.value)
                return [
                    "sampleType": "sleepAnalysis",
                    "value": sample.value,
                    "valueFloat": String(sample.value),
                    "unit": "",
                    "startDate": HealthKitSyncManager.isoFormatter.string(from: sample.startDate),
                    "endDate": HealthKitSyncManager.isoFormatter.string(from: sample.endDate),
                    "sourceName": sample.sourceRevision.source.name,
                    "sourceId": sample.sourceRevision.source.bundleIdentifier,
                    "metadata": ["sleepStage": stage],
                ]
            }

            completion(formatted)
        }

        healthStore.execute(query)
    }

    private func sleepStageString(from value: Int) -> String {
        if #available(iOS 16.0, *) {
            switch HKCategoryValueSleepAnalysis(rawValue: value) {
            case .asleepDeep: return "deep"
            case .asleepREM: return "rem"
            case .asleepCore: return "core"
            case .awake: return "awake"
            case .asleepUnspecified: return "asleep"
            default: return "asleep"
            }
        } else {
            switch value {
            case 0: return "asleep"
            case 1: return "awake"
            default: return "asleep"
            }
        }
    }

    private func queryWorkoutSamples(
        healthStore: HKHealthStore,
        startDate: Date,
        endDate: Date,
        completion: @escaping ([[String: Any]]) -> Void
    ) {
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: true
        )

        let query = HKSampleQuery(
            sampleType: HKWorkoutType.workoutType(),
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            guard let workouts = results as? [HKWorkout], error == nil else {
                completion([])
                return
            }

            let formatted = workouts.map { workout -> [String: Any] in
                var metadata: [String: Any] = [
                    "workoutActivityType": workout.workoutActivityType.rawValue,
                    "duration": workout.duration,
                ]

                if let totalEnergy = workout.totalEnergyBurned {
                    metadata["totalEnergyBurned"] = totalEnergy.doubleValue(for: .kilocalorie())
                }
                if let totalDistance = workout.totalDistance {
                    metadata["totalDistance"] = totalDistance.doubleValue(for: .meter())
                }

                return [
                    "sampleType": "workout",
                    "value": workout.workoutActivityType.rawValue,
                    "valueFloat": String(workout.duration),
                    "unit": "sec",
                    "startDate": HealthKitSyncManager.isoFormatter.string(from: workout.startDate),
                    "endDate": HealthKitSyncManager.isoFormatter.string(from: workout.endDate),
                    "sourceName": workout.sourceRevision.source.name,
                    "sourceId": workout.sourceRevision.source.bundleIdentifier,
                    "metadata": metadata,
                ]
            }

            completion(formatted)
        }

        healthStore.execute(query)
    }

    private func getDeviceInfo() -> [String: Any] {
        let device = UIDevice.current
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

        return [
            "model": device.model,
            "systemVersion": device.systemVersion,
            "appVersion": appVersion,
        ]
    }
}
