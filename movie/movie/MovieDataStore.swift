import Foundation
import Combine
import CoreLocation

struct GroupedMovie: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let rating: String
    let runtime: Int
    let genres: [String]
    let posterURL: String
    let theaters: [Theater]
    let allShowtimes: [Showtime]
}

@MainActor
final class MovieDataStore: ObservableObject {
    @Published private(set) var theaters: [Theater] = []
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var coordinates: [UUID: CLLocationCoordinate2D] = [:]
    
    var uniqueMovies: [Movie] {
        Array(Set(movies)).sorted { $0.title < $1.title }
    }

    // Group movies by title, merge theaters and showtimes
    var groupedMovies: [GroupedMovie] {
        let moviesByTitle = Dictionary(grouping: theaters.flatMap { $0.movies }) { $0.title }
        return moviesByTitle.values.compactMap { group in
            guard let first = group.first else { return nil }
            let theatersWithMovie = theaters.filter { t in t.movies.contains(where: { $0.title == first.title }) }
            let allShowtimes = group.flatMap { $0.showtimes }
            return GroupedMovie(
                id: first.id,
                title: first.title,
                rating: first.rating,
                runtime: first.runtime,
                genres: first.genres,
                posterURL: first.posterURL,
                theaters: theatersWithMovie,
                allShowtimes: allShowtimes
            )
        }.sorted { $0.title < $1.title }
    }
    
    private(set) var theatersByMovie: [UUID: [Theater]] = [:]
    private(set) var movieByID: [UUID: Movie] = [:]
    private(set) var theaterByID: [UUID: Theater] = [:]
    
    private let geocoder = CLGeocoder()
    
    init() {
        // Data loading is now triggered by the view's .onAppear modifier
    }
    
    func loadAllData() {
        // Only show the full-screen loader if there is no data at all
        if theaters.isEmpty {
            isLoading = true
        }
        errorMessage = nil
        
        Task {
            do {
                let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
                let date = today.replacingOccurrences(of: "/", with: "-")
                let result = try await MovieService.fetchTheaters(zipCode: "10001", date: date)
                
                await updateData(with: result)
                await geocodeTheaters(result)
            } catch {
                await handleError(error)
            }
        }
    }
    
    private func updateData(with theaters: [Theater]) async {
        let movies = Array(Set(theaters.flatMap { $0.movies }))
        let movieByID = Dictionary(uniqueKeysWithValues: movies.map { ($0.id, $0) })
        let theaterByID = Dictionary(uniqueKeysWithValues: theaters.map { ($0.id, $0) })
        var tByM: [UUID: [Theater]] = [:]
        
        for theater in theaters {
            for movie in theater.movies {
                tByM[movie.id, default: []].append(theater)
            }
        }
        
        await MainActor.run {
            self.theaters = theaters
            self.movies = movies
            self.movieByID = movieByID
            self.theaterByID = theaterByID
            self.theatersByMovie = tByM
            self.isLoading = false
        }
    }
    
    private func handleError(_ error: Error) async {
        await MainActor.run {
            self.errorMessage = "Failed to load data. Please try again."
            self.isLoading = false
        }
    }
    
    private func geocodeTheaters(_ theaters: [Theater]) async {
        for theater in theaters {
            let theaterID = theater.id
            let address = theater.address
            
            // Skip if we already have coordinates
            if coordinates[theaterID] != nil { continue }
            
            do {
                if let placemark = try? await geocoder.geocodeAddressString(address).first,
                   let loc = placemark.location {
                    let coordinate = loc.coordinate
                    await MainActor.run {
                        self.coordinates[theaterID] = coordinate
                    }
                }
                try await Task.sleep(nanoseconds: 200_000_000)
            } catch {
                continue
            }
        }
    }
}