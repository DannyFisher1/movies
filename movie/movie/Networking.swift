import Foundation

struct API {
    static let baseURL = "https://www.fandango.com/napi/theaterswithshowtimes"
    static let headers = [
        "User-Agent": "Mozilla/5.0",
        "Referer": "https://www.fandango.com/"
    ]
}

enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case serverError(String)
}

class MovieService {
    static func fetchTheaters(zipCode: String, date: String) async throws -> [Theater] {
        guard var components = URLComponents(string: API.baseURL) else {
            throw APIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "zipCode", value: zipCode),
            URLQueryItem(name: "date", value: date),
            URLQueryItem(name: "limit", value: "25"),
            URLQueryItem(name: "filter", value: "open-theaters"),
            URLQueryItem(name: "filterEnabled", value: "true"),
            URLQueryItem(name: "isdesktop", value: "true")
        ]
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        API.headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.requestFailed
        }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.decodingFailed
        }
        return try parseResponse(data: json)
    }

    private static func parseResponse(data: [String: Any]) throws -> [Theater] {
        var results: [Theater] = []
        guard let theaters = data["theaters"] as? [[String: Any]] else { return results }
        for theater in theaters {
            var movies: [Movie] = []
            for m in (theater["movies"] as? [[String: Any]] ?? []) {
                var showtimes: [Showtime] = []
                for variant in (m["variants"] as? [[String: Any]] ?? []) {
                    for group in (variant["amenityGroups"] as? [[String: Any]] ?? []) {
                        for s in (group["showtimes"] as? [[String: Any]] ?? []) {
                            let time = s["screenReaderTime"] as? String ?? ""
                            let url = s["ticketingJumpPageURL"] as? String ?? ""
                            showtimes.append(Showtime(time: time, ticketURL: url))
                        }
                    }
                }
                let poster = (((m["poster"] as? [String: Any])?["size"] as? [String: Any])?["300"] as? String) ?? ""
                let movie = Movie(
                    title: m["title"] as? String ?? "",
                    rating: m["rating"] as? String ?? "",
                    runtime: m["runtime"] as? Int ?? 0,
                    genres: m["genres"] as? [String] ?? [],
                    posterURL: poster,
                    showtimes: showtimes
                )
                movies.append(movie)
            }
            let theaterObj = Theater(
                name: theater["name"] as? String ?? "",
                address: theater["fullAddress"] as? String ?? "",
                movies: movies
            )
            results.append(theaterObj)
        }
        return results
    }
} 
