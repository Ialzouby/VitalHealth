//
//  VitalHealthApp.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import SwiftUI
import Firebase

@main
struct VitalHealthApp: App {
    let persistenceController = PersistenceController.shared
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            SignInView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
