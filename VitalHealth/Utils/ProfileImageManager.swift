//
//  ProfileImageManager.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import SwiftUI

class ProfileImageManager: ObservableObject {
    @Published var profileImage: UIImage? = nil

    init() {
        fetchProfileImage()
    }

    func fetchProfileImage() {
        // Try to load a saved profile image, or use a default placeholder
        if let savedImage = loadImageFromDisk(named: "profileImage") {
            profileImage = savedImage
        } else {
            profileImage = UIImage(systemName: "person.crop.circle.fill")
        }
    }

    func saveProfileImage(_ image: UIImage) {
        saveImageToDisk(image: image, named: "profileImage")
        profileImage = image
    }

    private func loadImageFromDisk(named name: String) -> UIImage? {
        guard let imagePath = getDocumentsDirectory()?.appendingPathComponent(name),
              let data = try? Data(contentsOf: imagePath),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    private func saveImageToDisk(image: UIImage, named name: String) {
        guard let data = image.jpegData(compressionQuality: 0.8),
              let path = getDocumentsDirectory()?.appendingPathComponent(name) else {
            return
        }
        try? data.write(to: path)
    }

    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
