import Foundation
import MapKit
import SwiftUI

@Observable class MapViewModel {
    var visibleRegion: [UUID: Location] = [:]
    var visibleRectangle = MKMapRect.null

    var region = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 54.1318, longitude: 8.8557), span: MKCoordinateSpan(latitudeDelta: 0.0167, longitudeDelta: 0.0167)))

    static let shared = MapViewModel()
    private init() {}

#if os(macOS)
    static let frameOffset = 0.0
#else
    static let frameOffset = 4_250.0
#endif

    @MainActor func updateRegion(for id: UUID, with location: Location) -> Void {
        self.visibleRegion[id] = location
        let maxDistance = Self.greatestDistance(locations: Array(self.visibleRegion.values))
        for location in self.visibleRegion.values {
            let boundingRectangle = Self.makeBoundingRectangle(
                centerCoordinate: location.coordinate, widthMeters: (maxDistance.value / 2) + Self.frameOffset, heightMeters: (maxDistance.value / 2) + Self.frameOffset)
            self.visibleRectangle = self.visibleRectangle.union(boundingRectangle)
        }
        self.region = MapCameraPosition.region(MKCoordinateRegion(self.visibleRectangle))
    }

    private static func greatestDistance(locations: [Location]) -> Measurement<UnitLength> {
        var maxDistance = Measurement<UnitLength>(value: 0.0, unit: .meters)
        for i in 0 ..< locations.count {
            for j in i + 1 ..< locations.count {
                let distance = haversineDistance(location_0: locations[i], location_1: locations[j])
                if distance > maxDistance {
                    maxDistance = distance
                }
            }
        }
        return maxDistance
    }

    private static func makeBoundingRectangle(centerCoordinate: CLLocationCoordinate2D, widthMeters: Double, heightMeters: Double) -> MKMapRect {
        // Convert center coordinate to map point
        let centerPoint = MKMapPoint(centerCoordinate)

        // Calculate points per meter at this latitude
        let metersPerPoint = MKMetersPerMapPointAtLatitude(centerCoordinate.latitude)

        // Convert meters to points
        let widthPoints = widthMeters / metersPerPoint
        let heightPoints = heightMeters / metersPerPoint

        // Create rect centered on the point
        return MKMapRect(
            x: centerPoint.x - widthPoints / 2,
            y: centerPoint.y - heightPoints / 2,
            width: widthPoints,
            height: heightPoints
        )
    }

}

extension MapViewModel {
    // Creates a binding for any property
    func binding<Value>(for keyPath: ReferenceWritableKeyPath<MapViewModel, Value>) -> Binding<Value> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }
}
