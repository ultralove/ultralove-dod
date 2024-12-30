import CoreLocation
import Foundation

protocol LocationControllerDelegate: NSObjectProtocol {
    func locationController(didUpdateLocation location: Location) async -> Void
}

class LocationController: NSObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    var delegate: LocationControllerDelegate?
    var location: Location?

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            Task {
                let latitude = lastLocation.coordinate.latitude
                let longitude = lastLocation.coordinate.longitude
                if let placemark = await Self.reverseGeocodeLocation(latitude: latitude, longitude: longitude) {
                    let newLocation = Location(name: placemark, latitude: latitude, longitude: longitude)
                    if self.location != newLocation {
                        self.location = newLocation
                        if let delegate = self.delegate {
                            await delegate.locationController(didUpdateLocation: newLocation)
                        }
                    }
                }
            }
        }
    }

    private static func reverseGeocodeLocation(latitude: Double, longitude: Double) async -> String? {
        var location: String?
        do {
            let geocoder = CLGeocoder()
            let coordinate = CLLocation(latitude: latitude, longitude: longitude)
            let placemarks = try await geocoder.reverseGeocodeLocation(coordinate)
            if let placemark = placemarks.first {
                var str = ""
                if let thoroughfare = placemark.thoroughfare, let subThoroughfare = placemark.subThoroughfare {
                    str += thoroughfare + " " + subThoroughfare
                }
                if let postalCode = placemark.postalCode, let locality = placemark.locality {
                    if str.isEmpty == false {
                        str += ", "
                    }
                    str += postalCode + " " + locality
                    if let subLocality = placemark.subLocality {
                        if str.isEmpty == false {
                            str += "-"
                        }
                        str += subLocality
                    }
                }
                if str.isEmpty == false {
                    location = str
                }
            }
        }
        catch {
            print("Failed to reverse geocode location: \(error)")
            location = nil
        }
        return location
    }
}
