//
//  MainView.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0 // Track the selected tab

    var body: some View {
        TabView(selection: $selectedTab) {
            // HomeView for Summary
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Summary")
                }
                .tag(0)

            // GymView for Gym
            GymView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Gym")
                }
                .tag(1)

            // GoalsView for Goals
            GoalsView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
                .tag(2)
        }
    }
}
