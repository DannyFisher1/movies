import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    let theater: Theater
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AsyncImage(url: URL(string: movie.posterURL)) { phase in
                    switch phase {
                    case .empty:
                        Color(.systemGray5)
                            .frame(width: 220, height: 330)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 330)
                    case .failure:
                        Color(.systemGray5)
                            .frame(width: 220, height: 330)
                            .overlay(
                                Image(systemName: "film")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text(movie.title)
                        .font(.title.bold())
                        .foregroundColor(.white)
                    HStack(spacing: 16) {
                        Text(movie.rating)
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        Text("\(movie.runtime) min")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    if !movie.genres.isEmpty {
                        Text(movie.genres.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Showtimes")
                        .font(.headline)
                        .foregroundColor(.white)
                    if movie.showtimes.isEmpty {
                        Text("No showtimes available.")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    } else {
                        ForEach(movie.showtimes) { showtime in
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
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding(.top)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(.black), Color(.darkGray)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .navigationTitle(theater.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}