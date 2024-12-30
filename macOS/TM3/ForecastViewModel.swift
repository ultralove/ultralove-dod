import SwiftUI

@Observable class ForecastViewModel: LocationViewModel {
    private let forecastController = ForecastController()

    var forecast: [Forecast] = []
    var timestamp: Date? = nil

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
            self.timestamp = nil
            if let forcastSensor = try await forecastController.refreshForecast(for: location) {
                self.forecast = forcastSensor.forecast
                self.timestamp = forcastSensor.timestamp 
            }
        }
        catch {
            print("Error refreshing data: \(error)")
        }
    }

    var trendSymbol: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.now.nearestHour() {
            if let currentTemperature = forecast.first(where: { $0.date == currentDate })?.temperature {
                if let nextDate = currentDate.nextNearestHour() {
                    if let nextTemperature = forecast.first(where: { $0.date == nextDate })?.temperature {
                        if currentTemperature > nextTemperature {
                            symbol = "arrow.down.forward.circle"
                        }
                        else if currentTemperature < nextTemperature {
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
