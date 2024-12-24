import CoreLocation
import MapKit
import SwiftUI

@Observable class LocationViewModel: NSObject, LocationControllerDelegate {
    private let locationController = LocationController()
    private var timer: Timer?
    var updateInterval: Double = 60 * 60
    var location: Location?
    var region = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 54.1318, longitude: 8.8557), span: MKCoordinateSpan(latitudeDelta: 0.0167, longitudeDelta: 0.0167)))

    var coordinate: CLLocationCoordinate2D {
        guard let location else { return .init() }
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    init(updateInterval: Double) {
        super.init()
        self.updateInterval = updateInterval
        self.locationController.delegate = self
        self.timer = Timer.scheduledTimer(timeInterval: self.updateInterval, target: self, selector: #selector(refreshHandler), userInfo: nil, repeats: true)
    }

    override convenience init() {
        self.init(updateInterval: 60 * 60)
    }

    func locationController(didUpdateLocation location: Location) -> Void {
        self.location = location
        self.region = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.0167,
                    longitudeDelta: 0.0167
                )
            )
        )
        self.refreshHandler()
    }

    @objc private func refreshHandler() -> Void {
        if let location = self.location {
            Task {
                await self.refreshData(location: location)
            }
        }
    }

    func refreshData(location: Location) async -> Void {
        preconditionFailure("refreshData() must be implemented by subclass")
    }
}
