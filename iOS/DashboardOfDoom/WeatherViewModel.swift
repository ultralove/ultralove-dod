import CoreLocation
import SwiftUI

@Observable class WeatherViewModel: LocationViewModel {
    private let weatherController = WeatherController()

    var actualTemperature: Measurement<UnitTemperature>?
    var apparentTemperature: Measurement<UnitTemperature>?
    var humidity: Double = 0.0
    var pressure: Measurement<UnitPressure>?


    var conditionsSymbol: String = "questionmark.circle"
    var timestamp: Date? = nil

    var faceplate: String {
        if let temperature = self.apparentTemperature?.value, let symbol = self.apparentTemperature?.unit.symbol {
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
            self.timestamp = nil
            if let weatherSensor = try await weatherController.refreshWeather(for: location) {
                self.actualTemperature = weatherSensor.weather.temperature
                self.apparentTemperature = weatherSensor.weather.apparentTemperature
                self.humidity = weatherSensor.weather.humidity
                self.pressure = weatherSensor.weather.pressure
                self.conditionsSymbol = weatherSensor.weather.conditionsSymbol
                self.timestamp = weatherSensor.timestamp
            }
        }
        catch {
            print("Error refreshing data: \(error)")
        }
    }
}
