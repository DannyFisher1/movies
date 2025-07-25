//
//  movieApp.swift
//  movie
//
//  Created by Danny Fisher on 7/23/25.
//

import SwiftUI
import Combine

@main
struct movieApp: App {
    @StateObject private var dataStore = MovieDataStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
        }
    }
}
