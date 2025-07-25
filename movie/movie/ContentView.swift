//
//  ContentView.swift
//  movie
//
//  Created by Danny Fisher on 7/23/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: MovieDataStore
    @State private var showMap: Bool = false
    @State private var selectedMovie: GroupedMovie? = nil
    @State private var selectedTheater: Theater? = nil
    
    var body: some View {
        ZStack(alignment: .top) {
            if dataStore.isLoading {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.7), Color.black]), startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    VStack(spacing: 32) {
                        Spacer()
                        Text("🎬")
                            .font(.system(size: 80))
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        Text("Movie Explorer")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        ClapperLoadingView()
                            .frame(width: 64, height: 64)
                            .background(Color.clear)
                        Spacer()
                    }
                }
                .allowsHitTesting(false)
                .zIndex(10)
            } else if let error = dataStore.errorMessage {
                VStack {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    Spacer()
                }
                .background(Color.black.opacity(0.2).ignoresSafeArea())
                .zIndex(11)
            } else {
                ZStack(alignment: .top) {
                    // Map full screen when showMap is true
                    if showMap {
                        TheaterListView(
                            theaters: dataStore.theaters,
                            onDismiss: {},
                            coordinates: dataStore.coordinates,
                            showMap: true,
                            fitToTheaters: false
                        )
                        .ignoresSafeArea()
                        .zIndex(0)
                    } else {
                        MovieListView(movies: dataStore.groupedMovies) { groupedMovie in
                            selectedMovie = groupedMovie
                        }
                        .zIndex(0)
                    }
                    // Overlay toggle and top bar
                    HStack {
                        Spacer()
                        MovieMapToggle(isMap: $showMap)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 32)
                    .padding(.bottom, 12)
                    .zIndex(2)
                }
                .accentColor(Color.orange)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $selectedMovie) { groupedMovie in
            GroupedMovieTheaterListView(groupedMovie: groupedMovie)
        }
        .onAppear {
            // Load data only if it hasn't been loaded before.
            // This prevents reloading when a sheet is dismissed.
            if dataStore.theaters.isEmpty {
                dataStore.loadAllData()
            }
        }
    }
}

struct MovieMapToggle: View {
    @Binding var isMap: Bool
    var body: some View {
        HStack(spacing: 0) {
            Button(action: { withAnimation { isMap = false } }) {
                Image(systemName: "film")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(!isMap ? .white : .gray)
                    .frame(width: 44, height: 36)
                    .background(!isMap ? Color.orange.opacity(0.9) : Color.clear)
                    .clipShape(Capsule())
            }
            Button(action: { withAnimation { isMap = true } }) {
                Image(systemName: "map")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isMap ? .white : .gray)
                    .frame(width: 44, height: 36)
                    .background(isMap ? Color.orange.opacity(0.9) : Color.clear)
                    .clipShape(Capsule())
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        .overlay(
            Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// Placeholder for loading animation
struct ClapperLoadingView: View {
    @State private var isClapping = false
    var body: some View {
        ZStack {
            Text("🎬")
                .font(.system(size: 64))
                .rotationEffect(.degrees(isClapping ? -20 : 0), anchor: .bottom)
                .scaleEffect(isClapping ? 1.1 : 1.0)
                .animation(Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: isClapping)
        }
        .onAppear {
            isClapping = true
        }
    }
}

#Preview {
    ContentView()
}