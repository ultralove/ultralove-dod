import CoreLocation
import Foundation

public struct Location: Equatable, Hashable {
   public let latitude: Double
   public let longitude: Double

    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
