//
//  HomeView.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import SwiftUI
import FirebaseAuth


struct HomeView: View {
    @State private var steps: Double = 0
    @State private var sleep: Double = 0
    @State private var distance: Double = 0 // Distance in miles
    @State private var restingHeartRate: Double? // Resting heart rate
    @State private var showImagePicker = false // Track image picker presentation
    @StateObject private var profileImageManager = ProfileImageManager() // Manage profile image
    @State private var selectedTab = 0 // Track the selected tab
    @State private var screenTime: Double = 0 // Screen Time in minutes
    @State private var sittingTime: Double = 0 // Sitting Time in minutes
    @State private var standingTime: Double = 0 // Standing Time in minutes
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Top Section: Summary with Profile Picture
                HStack {
                    Text("Summary")
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading)
                    
                    Spacer()
                    
                    // Replace Button with Menu
                    Menu {
                        // Edit Profile Image
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Label("Edit Profile Image", systemImage: "pencil")
                        }
                        
                        // Logout
                        Button(action: {
                            handleLogout()
                        }) {
                            Label("Logout", systemImage: "arrowshape.turn.up.left")
                        }
                    } label: {
                        if let profileImage = profileImageManager.profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.trailing)
                }
                .padding(.top)
                
                // Scrollable Content
                ScrollView {
                    VStack(spacing: 16) {
                        // Steps Summary
                        SummaryCardView(
                            title: "Steps Today",
                            value: "\(Int(steps))",
                            subtitle: "Goal: 10,000 steps",
                            icon: "flame.fill",
                            iconColor: .orange
                        )
                        
                        // Sleep Summary
                        SummaryCardView(
                            title: "Sleep",
                            value: "\(Int(sleep / 60))h \(Int(sleep.truncatingRemainder(dividingBy: 60)))m",
                            subtitle: "Time In Bed",
                            icon: "bed.double.fill",
                            iconColor: .blue
                        )
                        
                        // Walking/Running Distance
                        SummaryCardView(
                            title: "Walking + Running Distance",
                            value: "\(String(format: "%.2f", distance)) miles",
                            subtitle: "Today's Progress",
                            icon: "figure.walk",
                            iconColor: .green
                        )
                        
                        // Add Sitting Time Summary
                        SummaryCardView(
                            title: "Sitting Time",
                            value: "\(Int(sittingTime)) mins",
                            subtitle: "Time Spent Sitting",
                            icon: "chair.fill",
                            iconColor: .blue
                        )
                        
                        // Add Standing Time Summary
                        SummaryCardView(
                            title: "Standing Time",
                            value: "\(Int(standingTime)) mins",
                            subtitle: "Time Spent Standing",
                            icon: "figure.stand",
                            iconColor: .green
                        )
                        
                        // Resting Heart Rate
                        if let restingHeartRate = restingHeartRate {
                            SummaryCardView(
                                title: "Resting Heart Rate",
                                value: "\(Int(restingHeartRate)) BPM",
                                subtitle: "Average Today",
                                icon: "heart.fill",
                                iconColor: .red
                            )
                        } else {
                            SummaryCardView(
                                title: "Resting Heart Rate",
                                value: "Loading...",
                                subtitle: "Fetching resting heart rate...",
                                icon: "heart.fill",
                                iconColor: .red
                            )
                        }
                    }
                    .padding(.vertical)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $profileImageManager.profileImage, onImagePicked: { image in
                    profileImageManager.saveProfileImage(image)
                })
            }
            .onAppear {
                requestHealthKitData()
            }
        }
    }
    
    private func requestHealthKitData() {
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                // Fetch steps
                HealthKitManager.shared.fetchStepCount { steps in
                    DispatchQueue.main.async {
                        self.steps = steps
                        print("Steps: \(steps)")
                    }
                }
                
                // Fetch sleep
                HealthKitManager.shared.fetchSleepData { sleep in
                    DispatchQueue.main.async {
                        self.sleep = sleep
                        print("Sleep: \(sleep)")
                    }
                }
                
                // Fetch walking/running distance
                HealthKitManager.shared.fetchWalkingRunningDistance { distance in
                    DispatchQueue.main.async {
                        self.distance = distance * 0.000621371 // Convert meters to miles
                        print("Distance: \(self.distance) miles")
                    }
                }
                
                // Fetch resting heart rate
                HealthKitManager.shared.fetchRestingHeartRate { heartRate in
                    DispatchQueue.main.async {
                        self.restingHeartRate = heartRate
                        print("Resting Heart Rate: \(String(describing: heartRate))")
                    }
                }
            } else {
                print("HealthKit authorization failed: \(String(describing: error))")
            }
        }
    }
    
    private func handleLogout() {
        // Perform Firebase sign-out
        do {
            try Auth.auth().signOut()
            print("Firebase user signed out")
        } catch {
            print("Error signing out Firebase user: \(error.localizedDescription)")
        }
        
        // Remove Apple Sign-In Keychain data
        let keychainQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "appleUserIdentifier"
        ] as CFDictionary
        
        let status = SecItemDelete(keychainQuery)
        if status == errSecSuccess {
            print("Apple Sign-In Keychain data removed")
        } else {
            print("Error removing Keychain data: \(status)")
        }

        // Redirect to SignInView
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Unable to find windowScene or window")
            return
        }

        window.rootViewController = UIHostingController(rootView: SignInView())
        window.makeKeyAndVisible()
    }



    
    struct NavBarButton: View {
        let icon: String
        let label: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(isSelected ? .blue : .gray)
                    Text(label)
                        .font(.footnote)
                        .foregroundColor(isSelected ? .blue : .gray)
                }
            }
        }
    }
}
