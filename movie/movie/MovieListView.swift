import SwiftUI

struct MovieListView: View {
    let movies: [GroupedMovie]
    let onMovieTap: (GroupedMovie) -> Void
    @State private var selectedMovie: GroupedMovie? = nil
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("All Movies")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding(.top, 24)
                    .padding(.horizontal)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 12)], spacing: 16) {
                        ForEach(movies) { movie in
                            MovieCardView(movie: movie) {
                                onMovieTap(movie)
                            }
                        }
                    }
                }
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(.black), Color(.darkGray)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }
}

struct MovieCardView: View {
    let movie: GroupedMovie
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                AsyncImage(url: URL(string: movie.posterURL)) { phase in
                    switch phase {
                    case .empty:
                        Color(.systemGray5)
                            .aspectRatio(2/3, contentMode: .fit)
                            .frame(width: 140, height: 210)
                            .opacity(0.5)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(2/3, contentMode: .fit)
                            .frame(width: 140, height: 210)
                            .clipped()
                    case .failure:
                        Color(.systemGray5)
                            .aspectRatio(2/3, contentMode: .fit)
                            .frame(width: 140, height: 210)
                            .overlay(
                                Image(systemName: "film")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                VStack(spacing: 6) {
                    Text(movie.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    HStack(spacing: 8) {
                        Text(movie.rating)
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("\(movie.runtime) min")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    if !movie.genres.isEmpty {
                        Text(movie.genres.joined(separator: ", "))
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 10)
            }
            .frame(width: 170, height: 290)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Card corner radius helper
fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = 0.0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
} 
