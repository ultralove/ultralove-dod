import Foundation
import CoreLocation

struct Location: Equatable {
   var name: String
   let latitude: Double
   let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
