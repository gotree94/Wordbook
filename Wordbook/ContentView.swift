//
//  ContentView.swift
//  Wordbook
//
//  Created by gotree94 on 2/2/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        WordSetListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WordSet.self, inMemory: true)
}
