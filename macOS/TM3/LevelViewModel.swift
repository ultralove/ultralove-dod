import SwiftUI

@Observable class LevelViewModel: LocationViewModel {
    private let levelController = LevelController()

    var station: String?
    var measurements: [Level] = []
    var timestamp: Date?

    var maxLevel: Double {
        return measurements.map({ $0.measurement.value }).max() ?? 0.0
    }

    var trendSymbol: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToLastDayChange(from: Date.now) {
            if let currentIncidence = measurements.first(where: { $0.timestamp == currentDate })?.measurement.value {
                if let nextDate = Date.roundToLastDayChange(from: Date.now.addingTimeInterval(60 * 60 * 24)) {
                    if let nextIncidence = measurements.first(where: { $0.timestamp == nextDate })?.measurement.value {
                        if currentIncidence > nextIncidence {
                            symbol = "arrow.down.forward.circle"
                        }
                        else if currentIncidence < nextIncidence {
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
            if let levelSensor = try await levelController.refreshLevel(for: location) {
                self.station = levelSensor.station
                self.measurements = levelSensor.measurements
                self.timestamp = levelSensor.timestamp
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")

        }
    }
}
