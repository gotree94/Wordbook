//
//  WordbookApp.swift
//  Wordbook
//
//  Created by gotree94 on 2/2/26.
//

import SwiftUI
import SwiftData

@main
struct WordbookApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WordSet.self,
            Word.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

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
