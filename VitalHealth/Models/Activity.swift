//
//  Activity.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import Foundation

struct Activity: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: String // e.g., "Physical", "Productivity"
    var duration: Int // In minutes
    var goal: Int? // Optional goal value
    var progress: Int // Current progress

    init(name: String, type: String, duration: Int = 0, goal: Int? = nil, progress: Int = 0) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.duration = duration
        self.goal = goal
        self.progress = progress
    }
}
