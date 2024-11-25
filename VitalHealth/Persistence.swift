//
//  Persistence.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Add sample data for preview
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        // Use NSPersistentCloudKitContainer for CloudKit support
        container = NSPersistentCloudKitContainer(name: "VitalHealth") // Ensure this matches your .xcdatamodeld name

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            guard let description = container.persistentStoreDescriptions.first else {
                fatalError("No descriptions found for persistent store!")
            }

            // Configure CloudKit container options
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.alzoubyissam.Vital-Health"
            )
        }

        // Load Persistent Stores
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("Persistent store loaded: \(storeDescription)")
            }
        }

        // Automatically merge changes from CloudKit
        container.viewContext.automaticallyMergesChangesFromParent = true

        // Set merge policies to handle conflicts
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // CloudKit sync debugging
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { notification in
            print("CloudKit sync triggered: \(notification)")
        }
    }



    // MARK: - Save Example Data
    func saveEntity(name: String) {
        let context = container.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: "YourEntityName", into: context)
        entity.setValue(name, forKey: "name") // Replace "name" with the appropriate key in your entity

        do {
            try context.save()
            print("Data saved successfully!")
        } catch {
            print("Failed to save data: \(error)")
        }
    }
}
