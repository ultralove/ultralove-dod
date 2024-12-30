import CoreLocation
import MapKit
import SwiftUI

@Observable class LocationViewModel: NSObject, LocationControllerDelegate {
    private let locationController = LocationController()
    private var timer: Timer?
    var updateInterval: Double = 60 * 10 // 10 minutes
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

        Timer.scheduledTimer(withTimeInterval: self.updateInterval, repeats: true) { _ in
            if let location = self.location {
                print("<<<<< Timer update: \(location) >>>>>")
                Task {
                    await self.refreshData(location: location)
                }
            }
        }
    }

    override convenience init() {
        self.init(updateInterval: 60 * 10) // 10 minutes
    }

    @MainActor func locationController(didUpdateLocation location: Location) async -> Void {
        if self.location == nil || haversineDistance(location_0: self.location!, location_1: location) > 100 {
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
            await self.onLocationUpdate()
        }
    }

    @MainActor private func onLocationUpdate() async -> Void {
        if let location = self.location {
            print("<<<<< Location update: \(location) >>>>>")
            await self.refreshData(location: location)
        }
    }

    func refreshData(location: Location) async -> Void {
        preconditionFailure("refreshData() must be implemented by subclass")
    }
}

extension LocationViewModel {
    // Creates a binding for any property
    func binding<Value>(for keyPath: ReferenceWritableKeyPath<LocationViewModel, Value>) -> Binding<Value> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }
}
