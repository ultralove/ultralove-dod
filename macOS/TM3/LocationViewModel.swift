import CoreLocation
import MapKit
import SwiftUI

@Observable class LocationViewModel: NSObject, Identifiable, LocationControllerDelegate {
    private let locationController = LocationController()
    private var timer: Timer?
    private var updateInterval: Double = 60 * 10 // 10 minutes

    let id = UUID()

    var location: Location?
    var placemark: String?

    static var visibleRegion: [UUID:Location] = [:]
    static var visibleRectangle = MKMapRect.null

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

        // Handle periodic updates
        Timer.scheduledTimer(withTimeInterval: self.updateInterval, repeats: true) { _ in
            if let location = self.location {
                Task {
                    await self.refreshData(location: location)
                }
            }
        }

        // Handle wake from sleep
        NotificationCenter.default.addObserver(forName: NSWorkspace.didWakeNotification, object: NSWorkspace.shared, queue: .main ) { notification in
            if let location = self.location {
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
        await self.updateLocation(location: location)
    }

    @MainActor func updateLocation(location: Location) async -> Void {
        var needsUpdate = false
        if(self.location == nil) {
            needsUpdate = true
        }
        else if self.significantLocationChange(previous: self.location, current: location) {
            needsUpdate = true
        }

        if needsUpdate == true {
            self.placemark = await LocationController.reverseGeocodeLocation(latitude: location.latitude, longitude: location.longitude)
            self.location = location
            await self.refreshData(location: location)
        }
    }

    @MainActor func updateRegion(for id: UUID, with location: Location) -> Void {
        Self.visibleRegion[id] = location
        for location in Self.visibleRegion.values {
            let mapPoint = MKMapPoint(location.coordinate)
            let pointRect = MKMapRect(x: mapPoint.x - 125_000, y: mapPoint.y - 125_000, width: 250_000, height: 250_000)
            Self.visibleRectangle = Self.visibleRectangle.union(pointRect)
        }
        self.region = MapCameraPosition.region(MKCoordinateRegion(Self.visibleRectangle))
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
