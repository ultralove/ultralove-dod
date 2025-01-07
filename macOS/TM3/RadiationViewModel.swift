import SwiftUI

@Observable class RadiationViewModel: LocationViewModel {
    private let radiationController = RadiationController()

    var station: String?
    var measurements: [Radiation] = []
    var timestamp: Date?

    var maxRadiation: Double {
        return measurements.map({ $0.total.value }).max() ?? 0.0
    }

    var trendSymbol: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToLastDayChange(from: Date.now) {
            if let currentRadiation = measurements.first(where: { $0.timestamp == currentDate })?.total.value {
                if let nextDate = Date.roundToLastDayChange(from: Date.now.addingTimeInterval(60 * 60 * 24)) {
                    if let nextRadiation = measurements.first(where: { $0.timestamp == nextDate })?.total.value {
                        if currentRadiation > nextRadiation {
                            symbol = "arrow.down.forward.circle"
                        }
                        else if currentRadiation < nextRadiation {
                            symbol = "arrow.up.forward.circle"
                        }
                        else {
                            symbol = "arrow.right.circle"
                        }
                    }
                }
            }
        }
        return symbol
    }

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
            self.timestamp = nil
            if let radiationSensor = try await radiationController.refreshRadiation(for: location) {
                self.station = radiationSensor.station
                self.measurements = radiationSensor.measurements
                self.timestamp = radiationSensor.timestamp
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")

        }
    }
}
