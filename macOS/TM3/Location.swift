import CoreLocation
import Foundation

struct Location: Equatable, Hashable {
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
