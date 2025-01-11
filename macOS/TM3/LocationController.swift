import CoreLocation

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
        #if os(macOS)
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        #else
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        #endif
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            Task {
                let latitude = lastLocation.coordinate.latitude
                let longitude = lastLocation.coordinate.longitude
                self.location = Location(latitude: latitude, longitude: longitude)
                if let delegate = self.delegate, let location = self.location {
                    await delegate.locationController(didUpdateLocation: location)
                }
            }
        }
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
//        if let thoroughfare = placemark.thoroughfare {
//            if formattedPlacemark.isEmpty == false {
//                formattedPlacemark += ", "
//            }
//            formattedPlacemark += thoroughfare
//            if let subThoroughfare = placemark.subThoroughfare {
//                formattedPlacemark += " " + subThoroughfare
//            }
//        }
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
