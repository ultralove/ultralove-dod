import SwiftUI

@Observable class ForecastViewModel: LocationViewModel {
    private let forecastController = ForecastController()

    var sensor: ForecastSensor?
    var measurements: [Forecast] = []
    var timestamp: Date? = nil

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
//            self.timestamp = nil
            if let sensor = try await forecastController.refreshForecast(for: location) {
                self.sensor = sensor
                self.measurements = sensor.forecast
                self.timestamp = sensor.timestamp
            }
        }
        catch {
            print("Error refreshing data: \(error)")
        }
    }

    var trend: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToPreviousHour(from: Date.now) {
            if let currentValue = self.measurements.first(where: { $0.date == currentDate })?.temperature {
                if let nextDate = Date.roundToNextHour(from: currentDate) {
                    if let nextValue = self.measurements.first(where: { $0.date == nextDate })?.temperature {
                        if currentValue > nextValue {
                            symbol = "arrow.down.forward.circle"
                        }
                        else if currentValue < nextValue {
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
}
