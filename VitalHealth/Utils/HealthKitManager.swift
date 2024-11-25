//
//  HealthKitManager.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()

    // Request authorization for HealthKit data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }

        // Data types to read
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }

    // Fetch today's steps
    func fetchStepCount(completion: @escaping (Double) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        healthStore.execute(query)
    }

    // Fetch sleep data
    func fetchSleepData(completion: @escaping (Double) -> Void) {
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 0, sortDescriptors: nil) { _, results, _ in
            guard let results = results as? [HKCategorySample] else {
                completion(0.0)
                return
            }

            let totalSleepMinutes = results.reduce(0.0) { (sum, sample) in
                let duration = sample.endDate.timeIntervalSince(sample.startDate) / 60
                return sum + duration
            }
            completion(totalSleepMinutes)
        }
        healthStore.execute(query)
    }
    
    func fetchRestingHeartRate(completion: @escaping (Double?) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 0, sortDescriptors: nil) { _, results, error in
            guard let results = results as? [HKQuantitySample], !results.isEmpty else {
                completion(nil) // No data available
                return
            }

            // Find the lowest heart rate value of the day
            let lowestHeartRate = results.map { sample in
                sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            }.min()

            completion(lowestHeartRate)
        }
        healthStore.execute(query)
    }
    
    func fetchStandingTime(completion: @escaping (Double) -> Void) {
        guard let standType = HKQuantityType.quantityType(forIdentifier: .appleStandTime) else {
            completion(0)
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: standType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }

            // Convert standing time to minutes
            let standingTimeInMinutes = sum.doubleValue(for: HKUnit.second()) / 60.0
            completion(standingTimeInMinutes)
        }
        healthStore.execute(query)
    }
    

    // Fetch walking/running distance
    func fetchWalkingRunningDistance(completion: @escaping (Double) -> Void) {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.meter()))
        }
        healthStore.execute(query)
    }
}

