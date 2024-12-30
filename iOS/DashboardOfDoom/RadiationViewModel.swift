import SwiftUI

@Observable class RadiationViewModel: LocationViewModel {
    private let radiationController = RadiationController()

    var station: Location?
    var radiation: Radiation?
    var timestamp: Date?

    var faceplate: String {
        if let value = self.radiation {
            return String(format: "%.3f%@", value.total.value, value.total.unit.symbol)
        }
        return "n/a"
    }

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
            self.timestamp = nil
            if let radiationSensor = try await radiationController.refreshRadiation(for: location) {
                self.station = radiationSensor.station
                self.radiation = radiationSensor.radiation
                self.timestamp = radiationSensor.timestamp
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")

        }
    }
}
