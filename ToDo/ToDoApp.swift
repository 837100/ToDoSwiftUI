//
//  ToDoAppApp.swift
//  ToDoApp
//
//  Created by SG on 1/17/25.
//

import SwiftUI
import SwiftData


@main
struct ToDoApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        
        }
        .modelContainer(sharedModelContainer)
    }
}
