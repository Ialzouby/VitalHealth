//
//  GymView.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import SwiftUI
import CoreData

struct GymView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)],
        animation: .default
    )
    private var exercises: FetchedResults<Exercise>

    @State private var isAddingExercise = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Header Section
                HStack {
                    Text("Gym")
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading)

                    Spacer()

                    Button(action: { isAddingExercise = true }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing)
                }
                .padding(.top)

                // Exercise List
                List {
                    ForEach(exercises) { exercise in
                        ExerciseCardView(exercise: exercise)
                            .swipeActions {
                                // Delete action
                                Button(role: .destructive) {
                                    deleteExercise(exercise)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
            }
        }
        // Add Exercise Modal
        .sheet(isPresented: $isAddingExercise) {
            AddExerciseView(onAdd: addExercise)
        }
        .onAppear {
            debugFetchExercises() // Debugging to check fetched data
        }
    }

    // MARK: - Core Data Functions

    private func addExercise(name: String, description: String) {
        withAnimation {
            let newExercise = Exercise(context: viewContext)
            newExercise.id = UUID()
            newExercise.name = name
            newExercise.exerciseDescription = description
            newExercise.isCompleted = false

            saveContext()
        }
    }

    private func deleteExercise(_ exercise: Exercise) {
        withAnimation {
            viewContext.delete(exercise)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
            print("Data saved successfully!")
        } catch {
            print("Error saving Core Data: \(error.localizedDescription)")
        }
    }

    private func debugFetchExercises() {
        do {
            let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
            let results = try viewContext.fetch(fetchRequest)
            print("Fetched exercises: \(results.map { $0.name ?? "Unknown" })")
        } catch {
            print("Error fetching exercises: \(error.localizedDescription)")
        }
    }
}

extension GymView {
    // MARK: - Exercise Card View
    struct ExerciseCardView: View {
        @ObservedObject var exercise: Exercise

        var body: some View {
            HStack {
                // Completion Toggle
                Button(action: {
                    toggleCompletion(for: exercise)
                }) {
                    Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(exercise.isCompleted ? .green : .gray)
                }
                .padding(.trailing)

                // Exercise Details
                VStack(alignment: .leading) {
                    Text(exercise.name ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(exercise.exerciseDescription ?? "")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.8))
                }

                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }

        private func toggleCompletion(for exercise: Exercise) {
            exercise.isCompleted.toggle()
            saveContext(for: exercise)
        }

        private func saveContext(for exercise: Exercise) {
            if let context = exercise.managedObjectContext {
                do {
                    try context.save()
                    print("Completion status updated for \(exercise.name ?? "Unknown").")
                } catch {
                    print("Error saving completion status: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Add Exercise View
    struct AddExerciseView: View {
        @Environment(\.dismiss) var dismiss
        @State private var name = ""
        @State private var description = ""

        var onAdd: (String, String) -> Void

        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Exercise Details")) {
                        TextField("Name", text: $name)
                        TextField("Description", text: $description)
                    }

                    Section {
                        Button(action: {
                            onAdd(name, description)
                            dismiss()
                        }) {
                            Text("Add Exercise")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .disabled(name.isEmpty) // Disable if name is empty
                    }
                }
                .navigationTitle("Add Exercise")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
