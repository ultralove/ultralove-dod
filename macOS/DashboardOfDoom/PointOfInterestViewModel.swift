import Foundation
import SwiftUI

@Observable class PointOfInterestViewModel: Identifiable, LocationManagerDelegate {
    let id = UUID()
    
    private let pointOfInterestController = PointOfInterestController()
    private let locationManager = LocationManager()
    private var location: Location?

    var pharmacies: [PointOfInterest]? = nil
    var hospitals: [PointOfInterest]? = nil
    var liquorStores: [PointOfInterest]? = nil
    var funeralDirectors: [PointOfInterest]? = nil
    var cemeteries: [PointOfInterest]? = nil

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
            self.pharmacies = await self.pointOfInterestController.fetchPharmacies(location: location)
            self.hospitals = await self.pointOfInterestController.fetchHospitals(location: location)
            self.liquorStores = await self.pointOfInterestController.fetchLiquorStores(location: location)
            self.funeralDirectors = await self.pointOfInterestController.fetchFuneralDirectors(location: location)
            self.cemeteries = await self.pointOfInterestController.fetchCemeteries(location: location)
        }
    }
}

extension PointOfInterestViewModel {
    // Creates a binding for any property
    func binding<Value>(for keyPath: ReferenceWritableKeyPath<PointOfInterestViewModel, Value>) -> Binding<Value> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }
}

