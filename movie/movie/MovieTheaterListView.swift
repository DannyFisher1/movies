import SwiftUI

struct MovieTheaterListView: View {
    let movie: Movie
    @EnvironmentObject var dataStore: MovieDataStore
    @State private var selectedTheater: Theater? = nil
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text(movie.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top, 24)
                    .padding(.horizontal)
                Text("Select a theater to see showtimes")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(dataStore.theatersByMovie[movie.id] ?? []) { theater in
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
            .sheet(item: $selectedTheater) { theater in
                ShowtimeListView(movie: movie, theater: theater)
            }
        }
    }
} 