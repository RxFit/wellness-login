import Foundation
import HealthKit
import UIKit

class HealthKitSyncManager {
    private let unitMapping: [HKQuantityTypeIdentifier: HKUnit] = [
        .heartRate: HKUnit.count().unitDivided(by: .minute()),
        .restingHeartRate: HKUnit.count().unitDivided(by: .minute()),
        .heartRateVariabilitySDNN: HKUnit.secondUnit(with: .milli),
        .stepCount: HKUnit.count(),
        .activeEnergyBurned: HKUnit.kilocalorie(),
        .basalEnergyBurned: HKUnit.kilocalorie(),
        .distanceWalkingRunning: HKUnit.meter(),
        .bodyMass: HKUnit.gramUnit(with: .kilo),
        .bodyFatPercentage: HKUnit.percent(),
        .oxygenSaturation: HKUnit.percent(),
        .respiratoryRate: HKUnit.count().unitDivided(by: .minute()),
        .vo2Max: HKUnit(from: "ml/kg*min"),
    ]

    private let unitStringMapping: [HKQuantityTypeIdentifier: String] = [
        .heartRate: "count/min",
        .restingHeartRate: "count/min",
        .heartRateVariabilitySDNN: "ms",
        .stepCount: "count",
        .activeEnergyBurned: "kcal",
        .basalEnergyBurned: "kcal",
        .distanceWalkingRunning: "m",
        .bodyMass: "kg",
        .bodyFatPercentage: "%",
        .oxygenSaturation: "%",
        .respiratoryRate: "count/min",
        .vo2Max: "ml/kg*min",
    ]

    private let sampleTypeNames: [HKQuantityTypeIdentifier: String] = [
        .heartRate: "heartRate",
        .restingHeartRate: "restingHeartRate",
        .heartRateVariabilitySDNN: "heartRateVariabilitySDNN",
        .stepCount: "stepCount",
        .activeEnergyBurned: "activeEnergyBurned",
        .basalEnergyBurned: "basalEnergyBurned",
        .distanceWalkingRunning: "distanceWalkingRunning",
        .bodyMass: "bodyMass",
        .bodyFatPercentage: "bodyFatPercentage",
        .oxygenSaturation: "oxygenSaturation",
        .respiratoryRate: "respiratoryRate",
        .vo2Max: "vo2Max",
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
            .heartRate, .restingHeartRate, .heartRateVariabilitySDNN,
            .stepCount, .activeEnergyBurned, .basalEnergyBurned,
            .distanceWalkingRunning, .bodyMass, .bodyFatPercentage,
            .oxygenSaturation, .respiratoryRate, .vo2Max,
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
                    "startDate": ISO8601DateFormatter().string(from: sample.startDate),
                    "endDate": ISO8601DateFormatter().string(from: sample.endDate),
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
                    "startDate": ISO8601DateFormatter().string(from: sample.startDate),
                    "endDate": ISO8601DateFormatter().string(from: sample.endDate),
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
                    "startDate": ISO8601DateFormatter().string(from: workout.startDate),
                    "endDate": ISO8601DateFormatter().string(from: workout.endDate),
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
