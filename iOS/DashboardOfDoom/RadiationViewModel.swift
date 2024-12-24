import SwiftUI

@Observable class RadiationViewModel: LocationViewModel {
    private let radiationController = RadiationController()

    static let shared = RadiationViewModel()

    var station: Location?
    var radiation: Radiation?
    var lastUpdate: Date? = nil

    override func refreshData(location: Location) async -> Void {
        do {
            self.lastUpdate = nil
            if let radiationSensor = try await radiationController.refreshRadiation(for: location) {
                self.station = radiationSensor.station
                self.radiation = radiationSensor.radiation
                self.lastUpdate = Date.now
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")

        }
    }
}
