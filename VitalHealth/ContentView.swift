//
//  ContentView.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var activityViewModel = ActivityViewModel() // ViewModel for activities
    @State private var isPresentingAddActivity = false // State for showing AddActivityView

    var body: some View {
        NavigationView {
            VStack {
                // Steps Summary
                VStack(alignment: .leading) {
                    Text("Steps Today")
                        .font(.headline)
                        .padding(.bottom, 2)
                    Text("\(Int(activityViewModel.stepCount)) steps")
                        .font(.largeTitle)
                        .bold()
                }
                .padding()

                // List of Activities
                List {
                    ForEach(activityViewModel.activities) { activity in
                        NavigationLink(destination: ActivityDetailView(activity: activity)) {
                            HStack {
                                Text(activity.name)
                                    .font(.headline)
                                Spacer()
                                if let goal = activity.goal {
                                    Text("\(activity.progress)/\(goal)")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                // Add New Activity Button
                Button(action: {
                    isPresentingAddActivity = true
                }) {
                    Label("Add Activity", systemImage: "plus")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
                .sheet(isPresented: $isPresentingAddActivity) {
                    AddActivityView()
                }
            }
            .navigationTitle("VitalHealth")
            .onAppear {
                activityViewModel.initializeActivities()
            }
        }
    }
}
