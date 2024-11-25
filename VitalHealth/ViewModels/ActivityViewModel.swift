//
//  ActivityViewModel.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var activities: [Activity] = [] // List of activities
    @Published var stepCount: Double = 0.0 // Today's steps
    
    // MARK: - Methods
    /// Fetch today's step count
    func fetchStepCount() {
        HealthKitManager.shared.fetchStepCount { [weak self] steps in
            DispatchQueue.main.async {
                self?.stepCount = steps
                self?.updateStepActivity(steps: steps)
            }
        }
    }
    
    /// Update the step-related activity in the activities list
    private func updateStepActivity(steps: Double) {
        if let index = activities.firstIndex(where: { $0.name == "Steps" }) {
            activities[index].progress = Int(steps)
        } else {
            // Add a new "Steps" activity if it doesn't exist
            let stepActivity = Activity(
                name: "Steps",
                type: "Physical",
                goal: 10000, // Example goal for steps
                progress: Int(steps)
            )
            activities.append(stepActivity)
        }
    }
    
    /// Initialize the ViewModel with default data or fetch from storage
    func initializeActivities() {
        // Example: Preload some activities (or load from a database later)
        activities = [
            Activity(name: "Cycling", type: "Physical", goal: 30, progress: 0), // Duration in minutes
            Activity(name: "Meditation", type: "Wellness", goal: 10, progress: 0)
        ]
        
        // Fetch the step count from HealthKit
        fetchStepCount()
    }
}
