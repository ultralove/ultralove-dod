import SwiftUI

@Observable class ForecastViewModel: LocationViewModel {
    private let forecastController = ForecastController()

    var sensor: ForecastSensor?
    var measurements: [Forecast] = []
    var timestamp: Date? = nil

    var maxValue: Measurement<UnitTemperature> {
        return measurements.map({ $0.temperature }).max() ?? Measurement<UnitTemperature>(value: -20.0, unit: .celsius)
    }

    var minValue: Measurement<UnitTemperature> {
        return Measurement<UnitTemperature>(value: -20.0, unit: .celsius)
    }

    var trend: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToPreviousHour(from: Date.now) {
            if let currentValue = self.measurements.first(where: { $0.timestamp == currentDate })?.temperature {
                if let nextDate = Date.roundToNextHour(from: currentDate) {
                    if let nextValue = self.measurements.first(where: { $0.timestamp == nextDate })?.temperature {
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

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
            //            self.timestamp = nil
            if let sensor = try await forecastController.refreshForecast(for: location) {
                self.sensor = sensor
                self.measurements = Self.sanitizeForecast(measurements: sensor.measurements)
                self.timestamp = sensor.timestamp
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
                    Forecast(temperature: measurement.temperature, apparentTemperature: measurement.apparentTemperature,
                             quality: quality, timestamp: measurement.timestamp))
        }
        return sanitizedForecast
    }
}
