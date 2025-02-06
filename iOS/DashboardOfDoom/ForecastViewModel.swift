import SwiftUI

@Observable class ForecastViewModel: LocationViewModel {
    private let forecastController = ForecastController()

    var sensor: ForecastSensor?
    var measurements: [Forecast] = []
    var timestamp: Date? = nil

    var maxValue: Measurement<UnitTemperature> {
        return Measurement<UnitTemperature>(value: 47.0, unit: .celsius)
    }

    var minValue: Measurement<UnitTemperature> {
        return Measurement<UnitTemperature>(value: -20.0, unit: .celsius)
    }

    var trend: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToPreviousHour(from: Date.now) {
            if let currentForecast = self.measurements.last(where: { $0.timestamp == currentDate }) {
                if let previousForecast = self.measurements.last(where: { $0.timestamp < currentForecast.timestamp }) {
                    let currentValue = currentForecast.temperature.value
                    let previousValue = previousForecast.temperature.value
                    if currentValue < previousValue {
                        symbol = "arrow.down.forward.circle"
                    }
                    else if currentValue > previousValue {
                        symbol = "arrow.up.forward.circle"
                    }
                    else {
                        symbol = "arrow.right.circle"
                    }
                }
            }
        }
        return symbol
    }

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await forecastController.refreshForecast(for: location) {
                self.sensor = sensor
                self.measurements = Self.sanitizeForecast(measurements: sensor.measurements)
                self.timestamp = sensor.timestamp
                self.updateRegion(for: self.id, with: sensor.location)
            }
        }
        catch {
            print("Error refreshing data: \(error)")
        }
    }

    private static func sanitizeForecast(measurements: [Forecast]) -> [Forecast] {
        var sanitizedForecast: [Forecast] = []
        for measurement in measurements {
            let quality = (measurement.timestamp < Date.now) ? QualityCode.good : QualityCode.uncertain
            sanitizedForecast.append(
                Forecast(
                    temperature: measurement.temperature, apparentTemperature: measurement.apparentTemperature,
                    symbol: measurement.symbol, quality: quality, timestamp: measurement.timestamp))
        }
        return sanitizedForecast
    }
}
