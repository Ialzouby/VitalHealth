//
//  GoalsView.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import SwiftUI

struct GoalsView: View {
    @State private var showImagePicker = false
    @StateObject private var profileImageManager = ProfileImageManager()

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
                // Header with Profile Picture
                HStack {
                    Text("Goals")
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading)

                    Spacer()

                    Button(action: {
                        showImagePicker = true
                    }) {
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

                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Your Goals")
                            .font(.headline)
                            .padding()

                        ForEach(0..<3, id: \.self) { index in
                            HStack {
                                Image(systemName: "target")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing)

                                VStack(alignment: .leading) {
                                    Text("Goal \(index + 1)")
                                        .font(.headline)
                                    Text("Description of goal \(index + 1)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $profileImageManager.profileImage, onImagePicked: { image in
                    profileImageManager.saveProfileImage(image)
                })
            }
        }
    }
}
