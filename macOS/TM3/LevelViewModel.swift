import SwiftUI

@Observable class LevelViewModel: LocationViewModel {
    private let levelController = LevelController()

    var station: String?
    var level: [Level] = []
    var timestamp: Date?

    var maxLevel: Double {
        return level.map({ $0.value }).max() ?? 0.0
    }

    var trendSymbol: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToLastDayChange(from: Date.now) {
            if let currentIncidence = level.first(where: { $0.date == currentDate })?.value {
                if let nextDate = Date.roundToLastDayChange(from: Date.now.addingTimeInterval(60 * 60 * 24)) {
                    if let nextIncidence = level.first(where: { $0.date == nextDate })?.value {
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
                self.level = levelSensor.level
                self.timestamp = levelSensor.timestamp
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")

        }
    }
}
