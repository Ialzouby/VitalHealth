//
//  ActivityDetailView.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import SwiftUI

struct ActivityDetailView: View {
    var activity: Activity // Pass the activity object to this view
    
    var body: some View {
        VStack {
            Text(activity.name)
                .font(.largeTitle)
                .padding()
            
            Text("Type: \(activity.type)")
                .font(.headline)
                .padding()
            
            if let goal = activity.goal {
                Text("Goal: \(goal)")
                    .font(.subheadline)
            }
            
            Text("Progress: \(activity.progress)")
                .font(.subheadline)
        }
        .navigationTitle(activity.name)
        .padding()
    }
}
