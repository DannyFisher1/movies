import SwiftUI

struct MovieGridView: View {
    let theater: Theater
    @State private var selectedMovie: Movie? = nil
    
    var body: some View {
        NavigationStack {
            // Main container VStack to hold the header and the scrollable grid
            VStack(spacing: 0) {
                
                // --- New Header Section ---
                VStack(alignment: .leading, spacing: 4) {
                    Text(theater.name)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(theater.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Divider().padding(.top, 8)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 12)
                // --- End of New Header Section ---
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 20)], spacing: 20) {
                        ForEach(theater.movies) { movie in
                            Button(action: {
                                selectedMovie = movie
                            }) {
                                VStack {
                                    AsyncImage(url: URL(string: movie.posterURL)) { phase in
                                        switch phase {
                                        case .empty:
                                            Color(.systemGray5)
                                                .frame(width: 120, height: 200)
                                                .cornerRadius(0)
                                                .opacity(0.5)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 200)
                                                .clipped()
                                        case .failure:
                                            Color(.systemGray5)
                                                .frame(width: 120, height: 200)
                                                .cornerRadius(0)
                                                .overlay(
                                                    Image(systemName: "film")
                                                        .font(.largeTitle)
                                                        .foregroundColor(.gray)
                                                )
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    Text(movie.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 8)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the VStack fills the screen
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(.black), Color(.darkGray)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationDestination(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie, theater: theater)
            }
        }
    }
}

// Simple shimmer effect for loading state
extension View {
    func shimmer() -> some View {
        self
            .redacted(reason: .placeholder)
            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.3), Color.clear]), startPoint: .leading, endPoint: .trailing)
                    .rotationEffect(.degrees(30))
                    .blendMode(.plusLighter)
                    .opacity(0.7)
            )
    }
}
