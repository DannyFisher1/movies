import SwiftUI

struct ShowtimeListView: View, Identifiable {
    let id = UUID()
    let movie: Movie
    let theater: Theater
    @Environment(\.openURL) var openURL
    
    var showtimes: [Showtime] {
        // FIX: Find the movie within the specific theater by its TITLE, not its unstable ID.
        theater.movies.first(where: { $0.title == movie.title })?.showtimes ?? []
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(movie.title)
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding(.top, 24)
                Text(theater.name)
                    .font(.headline)
                    .foregroundColor(.orange)
                Text(theater.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Divider().background(Color.gray)
                Text("Showtimes")
                    .font(.headline)
                    .foregroundColor(.white)
                if showtimes.isEmpty {
                    Text("No showtimes available.")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                } else {
                    ForEach(showtimes) { showtime in
                        Button(action: {
                            if let url = URL(string: showtime.ticketURL) {
                                openURL(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "ticket.fill")
                                    .foregroundColor(.orange)
                                Text(showtime.formattedTime)
                                    .foregroundColor(.white)
                                    .font(.body)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.darkGray).opacity(0.7))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 2)
                    }
                }
                Spacer()
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(.black), Color(.darkGray)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }
}
