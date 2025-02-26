import CoreLocation
import Foundation

protocol LocationManagerDelegate {
    func locationManager(didUpdateLocation location: Location) -> Void
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var location: Location?
    var delegate: LocationManagerDelegate?

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let latitude = lastLocation.coordinate.latitude
            let longitude = lastLocation.coordinate.longitude
            self.updateLocation(location: Location(latitude: latitude, longitude: longitude))
        }
    }

    func updateLocation(location: Location) -> Void {
        var needsUpdate = false
        if self.location == nil {
            needsUpdate = true
        }
        else if self.significantLocationChange(previous: self.location, current: location) {
            needsUpdate = true
        }
        if needsUpdate == true {
            self.location = location
            if let delegate = self.delegate {
                delegate.locationManager(didUpdateLocation: location)
            }
        }
    }

    private func significantLocationChange(previous: Location?, current: Location) -> Bool {
        guard let previous = previous else { return true }
        let deadband = Measurement(value: 100.0, unit: UnitLength.meters)
        let distance = haversineDistance(location_0: previous, location_1: current)
        return distance > deadband
    }

    static func reverseGeocodeLocation(latitude: Double, longitude: Double) async -> String? {
        var formattedPlacemark: String?
        do {
            let geocoder = CLGeocoder()
            let coordinate = CLLocation(latitude: latitude, longitude: longitude)
            let placemarks = try await geocoder.reverseGeocodeLocation(coordinate)
            if let placemark = placemarks.first {
                formattedPlacemark = formatPlacemarkLong(placemark: placemark)
            }
        }
        catch {
            print("Failed to reverse geocode location: \(error)")
            formattedPlacemark = nil
        }
        return formattedPlacemark
    }

    static func reverseGeocodeLocation(location: Location) async -> String? {
        return await self.reverseGeocodeLocation(latitude: location.latitude, longitude: location.longitude)
    }

    static private func formatPlacemarkLong(placemark: CLPlacemark) -> String? {
        var formattedPlacemark = ""

        if let name = placemark.name {
            formattedPlacemark += name
        }
        if let postalCode = placemark.postalCode, let locality = placemark.locality {
            if formattedPlacemark.isEmpty == false {
                formattedPlacemark += ", "
            }
            formattedPlacemark += postalCode + " " + locality
            if let subLocality = placemark.subLocality {
                if formattedPlacemark.isEmpty == false {
                    formattedPlacemark += "-"
                }
                formattedPlacemark += subLocality
            }
        }
        return formattedPlacemark
    }

    static private func formatPlacemarkShort(placemark: CLPlacemark) -> String? {
        var formattedPlacemark = ""
        if let locality = placemark.locality {
            formattedPlacemark += locality
        }
        if let subLocality = placemark.subLocality {
            formattedPlacemark += "-" + subLocality
        }
        return formattedPlacemark
    }
}
