import CoreLocation
import SwiftUI

@Observable class WeatherViewModel: LocationViewModel {
    private let weatherController = WeatherController()

    var actualTemperature: Measurement<UnitTemperature>?
    var apparentTemperature: Measurement<UnitTemperature>?
    var humidity: Double = 0.0
    var pressure: Measurement<UnitPressure>?

    var sensor: WeatherSensor?
    var symbol: String = "questionmark.circle"
    var timestamp: Date? = nil

    var faceplate: String {
        if let temperature = self.actualTemperature?.value, let symbol = self.actualTemperature?.unit.symbol {
            return String(format: "%.1f%@", temperature, symbol)
        }
        return "n/a"
    }

    var temperature: Measurement<UnitTemperature>? {
        let showPerceivedTemperature = UserDefaults.standard.bool(forKey: "showPerceivedTemperature")
        guard showPerceivedTemperature == true else {
            return apparentTemperature
        }
        return actualTemperature
    }

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await weatherController.refreshWeather(for: location) {
                self.actualTemperature = sensor.measurements.temperature
                self.apparentTemperature = sensor.measurements.apparentTemperature
                self.humidity = sensor.measurements.humidity
                self.pressure = sensor.measurements.pressure
                self.symbol = sensor.measurements.symbol
                self.sensor = sensor
                self.timestamp = sensor.timestamp
                self.updateRegion(for: self.id, with: sensor.location)
            }
        }
        catch {
            print("Error refreshing data: \(error)")
        }
    }
}
