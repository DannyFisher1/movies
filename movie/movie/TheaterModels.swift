import Foundation

struct Theater: Identifiable, Codable, Hashable {
    var id: UUID
    let name: String
    let address: String
    let movies: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, movies
    }
    
    init(id: UUID = UUID(), name: String, address: String, movies: [Movie]) {
        self.id = id
        self.name = name
        self.address = address
        self.movies = movies
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        movies = try container.decode([Movie].self, forKey: .movies)
    }
}

struct Movie: Identifiable, Codable, Hashable {
    var id: UUID
    let title: String
    let rating: String
    let runtime: Int
    let genres: [String]
    let posterURL: String
    let showtimes: [Showtime]
    
    enum CodingKeys: String, CodingKey {
        case id, title, rating, runtime, genres, posterURL, showtimes
    }
    
    init(id: UUID = UUID(), title: String, rating: String, runtime: Int, genres: [String], posterURL: String, showtimes: [Showtime]) {
        self.id = id
        self.title = title
        self.rating = rating
        self.runtime = runtime
        self.genres = genres
        self.posterURL = posterURL
        self.showtimes = showtimes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        rating = try container.decode(String.self, forKey: .rating)
        runtime = try container.decode(Int.self, forKey: .runtime)
        genres = try container.decode([String].self, forKey: .genres)
        posterURL = try container.decode(String.self, forKey: .posterURL)
        showtimes = try container.decode([Showtime].self, forKey: .showtimes)
    }
}

struct Showtime: Identifiable, Codable, Hashable {
    var id: UUID
    let time: String
    let ticketURL: String

    /// Provides a consistently formatted time string, e.g., "6:30 PM".
    var formattedTime: String {
        // First, clean up the inconsistent string from the API.
        // This turns "6 o'clock PM" into "6:00 PM".
        let cleanedTime = time.replacingOccurrences(of: " o'clock", with: ":00")
        
        // Try to parse the cleaned string into a Date object.
        if let date = Showtime.timeParser.date(from: cleanedTime) {
            // If successful, format it back into our desired string format.
            return Showtime.timeDisplayer.string(from: date)
        }
        
        // If parsing fails for any reason, return the original time as a safe fallback.
        return time
    }

    /// A static, reusable formatter to parse incoming time strings. It's static for efficiency.
    private static let timeParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Parses strings like "6:00 PM"
        return formatter
    }()
    
    /// A static, reusable formatter to display time strings consistently.
    private static let timeDisplayer: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Outputs strings like "6:00 PM"
        return formatter
    }()

    enum CodingKeys: String, CodingKey {
        case id, time, ticketURL
    }
    
    init(id: UUID = UUID(), time: String, ticketURL: String) {
        self.id = id
        self.time = time
        self.ticketURL = ticketURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        time = try container.decode(String.self, forKey: .time)
        ticketURL = try container.decode(String.self, forKey: .ticketURL)
    }
}