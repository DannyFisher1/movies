import SwiftUI
import MapKit

struct TheaterAnnotation: Identifiable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct TheaterListView: View {
    let theaters: [Theater]
    let onDismiss: () -> Void
    let coordinates: [UUID: CLLocationCoordinate2D]
    let showMap: Bool
    let fitToTheaters: Bool
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    // This now controls which theater is selected on the map AND which theater to show in the sheet.
    @State private var selectedTheaterForMap: TheaterAnnotation? = nil
    
    // This is the single source of truth for presenting the MovieGridView sheet.
    // When this is not nil, the sheet will show.
    @State private var theaterForMovieGrid: Theater? = nil

    // State for the second-level sheet (unchanged)
    @State private var showMovieDetail: Bool = false
    @State private var movieDetail: Movie? = nil

    var annotations: [TheaterAnnotation] {
        theaters.compactMap { theater in
            if let coord = coordinates[theater.id] {
                return TheaterAnnotation(id: theater.id, name: theater.name, coordinate: coord)
            }
            return nil
        }
    }

    var body: some View {
        ZStack {
            if showMap {
                ZStack {
                    Map {
                        ForEach(annotations) { item in
                            Annotation(item.name, coordinate: item.coordinate, anchor: .bottom) {
                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedTheaterForMap = item
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.orange.opacity(0.18))
                                            .frame(width: 44, height: 44)
                                            .blur(radius: 2)
                                        Circle()
                                            .fill(Color.orange)
                                            .frame(width: 18, height: 18)
                                            .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 0)
                                        Image(systemName: "popcorn.fill")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .shadow(color: .orange.opacity(0.7), radius: 4, x: 0, y: 0)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contentShape(Rectangle())
                            }
                        }
                    }
                    .mapStyle(.standard(elevation: .realistic))
                    .ignoresSafeArea()
                    .transition(.opacity)
                    
                    if let selected = selectedTheaterForMap, let theater = theaters.first(where: { $0.id == selected.id }) {
                        VStack {
                            Spacer()
                            MinimalTheaterOverlay(
                                theater: theater,
                                onClose: { withAnimation { selectedTheaterForMap = nil } },
                                onSeeMovies: {
                                    // FIX: Simply set the theater data. This will trigger the sheet.
                                    theaterForMovieGrid = theater
                                }
                            )
                            .padding(.bottom, 32)
                            .frame(maxWidth: .infinity)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            } else { // The list view for theaters
                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(theaters) { theater in
                            Button(action: {
                                // FIX: Simply set the theater data. This will trigger the sheet.
                                theaterForMovieGrid = theater
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
        }
        // FIX: Use .sheet(item:), which ties presentation to the existence of data.
        // This modifier is placed on the parent ZStack to serve both the map and list views.
        .sheet(item: $theaterForMovieGrid) { theater in
             MovieGridView(theater: theater)
        }
        // This second sheet for detail view remains unchanged, as it was already correct.
        .sheet(isPresented: $showMovieDetail) {
            if let movie = movieDetail, let theater = theaterForMovieGrid {
                MovieDetailView(movie: movie, theater: theater)
            }
        }
        .accentColor(.orange)
        .preferredColorScheme(.dark)
    }

    // Helper to fit region to all coordinates (unchanged)
    func regionThatFits(_ coords: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coords.isEmpty else { return region }
        var minLat = coords[0].latitude, maxLat = coords[0].latitude
        var minLon = coords[0].longitude, maxLon = coords[0].longitude
        for c in coords {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: max(0.02, (maxLat - minLat) * 1.5), longitudeDelta: max(0.02, (maxLon - minLon) * 1.5))
        return MKCoordinateRegion(center: center, span: span)
    }
}

struct MinimalTheaterOverlay: View {
    let theater: Theater
    let onClose: () -> Void
    let onSeeMovies: () -> Void
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Spacer()
                Capsule()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 4)
                Spacer()
            }
            Text(theater.name)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text(theater.address)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Button(action: onSeeMovies) {
                Text("See Movies")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 32)
                    .background(Color.orange.opacity(0.9))
                    .clipShape(Capsule())
            }
            .padding(.top, 6)
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.title2)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 8)
        .frame(maxWidth: 340)
        .padding(.bottom, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}