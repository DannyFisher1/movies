import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var zipCode: String? = nil
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String? = nil
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error.localizedDescription
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        fetchZipCode(from: location)
    }

    private func fetchZipCode(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                self?.locationError = error.localizedDescription
                return
            }
            if let zip = placemarks?.first?.postalCode {
                DispatchQueue.main.async {
                    self?.zipCode = zip
                }
            } else {
                self?.locationError = "Could not determine zip code."
            }
        }
    }
} 