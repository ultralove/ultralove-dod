import Foundation
import SwiftUI

@Observable class HotspotViewModel: LocationManagerDelegate {
    private let hotspotController = HotspotController()
    private let locationManager = LocationManager()
    private var location: Location?

    var pharmacies: [Hotspot]? = nil
    var hospitals: [Hotspot]? = nil
    var liquorStores: [Hotspot]? = nil
    var funeralDirectors: [Hotspot]? = nil
    var cemeteries: [Hotspot]? = nil

    init() {
        self.locationManager.delegate = self
    }

    func locationManager(didUpdateLocation location: Location) {
        self.location = location
        Task {
            await self.refresh()
        }
    }

    @MainActor func refresh() async {
        if let location = self.location {
            self.pharmacies = await self.hotspotController.fetchPharmacies(location: location)
            self.hospitals = await self.hotspotController.fetchHospitals(location: location)
            self.liquorStores = await self.hotspotController.fetchLiquorStores(location: location)
            self.funeralDirectors = await self.hotspotController.fetchFuneralDirectors(location: location)
            self.cemeteries = await self.hotspotController.fetchCemeteries(location: location)
        }
    }
}

extension HotspotViewModel {
    // Creates a binding for any property
    func binding<Value>(for keyPath: ReferenceWritableKeyPath<HotspotViewModel, Value>) -> Binding<Value> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }
}

