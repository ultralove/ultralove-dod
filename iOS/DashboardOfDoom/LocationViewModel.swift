import CoreLocation
import MapKit
import SwiftUI

@Observable class LocationViewModel: NSObject, Identifiable, LocationControllerDelegate {
    private let locationController = LocationController()
    private var timer: Timer?
    private var updateInterval: Double = 60 * 10 // 10 minutes

    let id = UUID()

    var location: Location?

    var coordinate: CLLocationCoordinate2D {
        guard let location else { return .init() }
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    init(updateInterval: Double) {
        super.init()
        self.updateInterval = updateInterval
        self.locationController.delegate = self

        // Handle periodic updates
        Timer.scheduledTimer(withTimeInterval: self.updateInterval, repeats: true) { _ in
            if let location = self.location {
                Task {
                    await self.refreshData(location: location)
                }
            }
        }

        // Handle wake from sleep
#if os(macOS)
        NotificationCenter.default.addObserver(forName: NSWorkspace.didWakeNotification, object: NSWorkspace.shared, queue: .main ) { notification in
            if let location = self.location {
                Task {
                    await self.refreshData(location: location)
                }
            }
        }
#endif
    }

    override convenience init() {
        self.init(updateInterval: 60 * 10)  // 10 minutes
    }

    @MainActor func locationController(didUpdateLocation location: Location) async -> Void {
        await self.updateLocation(location: location)
    }

    @MainActor func updateLocation(location: Location) async -> Void {
        var needsUpdate = false
        if self.location == nil {
            needsUpdate = true
        }
        else if self.significantLocationChange(previous: self.location, current: location) {
            needsUpdate = true
        }

        if needsUpdate == true {
            self.location = location
            await self.refreshData(location: location)
        }
    }

    private func significantLocationChange(previous: Location?, current: Location) -> Bool {
        guard let previous = previous else { return true }
        let deadband = Measurement(value: 100.0, unit: UnitLength.meters)
        let distance = haversineDistance(location_0: previous, location_1: current)
        return distance > deadband
    }

    func refreshData(location: Location) async -> Void {
        preconditionFailure("refreshData() must be implemented by subclass")
    }

    func refreshData() async -> Void {
        if let location = self.location {
            await self.refreshData(location: location)
        }
    }
}
