import SwiftUI

struct GroupedMovieTheaterListView: View, Identifiable {
    let id = UUID()
    let groupedMovie: GroupedMovie
    
    // This state will now drive the navigation to the detail view.
    @State private var selectedTheater: Theater? = nil
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text(groupedMovie.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top, 24)
                    .padding(.horizontal)
                Text("Select a theater to see showtimes")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(groupedMovie.theaters) { theater in
                            // This button's action now triggers the navigation destination below.
                            Button(action: {
                                selectedTheater = theater
                            }) {
                                HStack(spacing: 14) {
                                    Circle().fill(Color.orange).frame(width: 10, height: 10)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(theater.name)
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        Text(theater.address)
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 18)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                }
            }
            .background(Color.black.ignoresSafeArea())
          
            .navigationDestination(item: $selectedTheater) { theater in
                if let movieForThisTheater = theater.movies.first(where: { $0.title == groupedMovie.title }) {
                    MovieDetailView(movie: movieForThisTheater, theater: theater)
                } else {
                    // Fallback view in the rare case the movie isn't found.
                    Text("Error: Could not load movie details for this theater.")
                }
            }
        }
    }
}


