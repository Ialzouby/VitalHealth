//
//  Goal.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import Foundation

struct Goal: Identifiable, Codable {
    let id: UUID
    var activityId: UUID
    var target: Int
    var period: String // "Daily", "Weekly", "Monthly"
    var achieved: Bool

    init(activityId: UUID, target: Int, period: String, achieved: Bool = false) {
        self.id = UUID()
        self.activityId = activityId
        self.target = target
        self.period = period
        self.achieved = achieved
    }
}
