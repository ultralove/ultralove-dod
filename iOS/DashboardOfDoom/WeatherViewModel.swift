import CoreLocation
import SwiftUI

@Observable class WeatherViewModel: LocationViewModel {
    private let weatherController = WeatherController()

    static let shared = WeatherViewModel()

    var actualTemperature: Measurement<UnitTemperature>?
    var apparentTemperature: Measurement<UnitTemperature>?
    var conditionsSymbol: String = "questionmark.circle"
    var lastUpdate: Date? = nil

    var faceplate: String {
        if let temperature = self.actualTemperature?.value {
            return String(format: "%.1f°", temperature)
        }
        return "n/a"
    }

    var temperature: Measurement<UnitTemperature>? {
        let showPerceivedTemperature = UserDefaults.standard.bool(forKey: "showPerceivedTemperature")
        guard showPerceivedTemperature == true else {
            return actualTemperature
        }
        return apparentTemperature
    }

    override func refreshData(location: Location) async -> Void {
        do {
            lastUpdate = nil
            if let weatherSensor = try await weatherController.refreshWeather(for: location) {
                self.actualTemperature = weatherSensor.weather.temperature
                self.apparentTemperature = weatherSensor.weather.apparentTemperature
                self.conditionsSymbol = weatherSensor.weather.conditionsSymbol
                self.lastUpdate = Date.now
            }
        }
        catch {
            print("Error refreshing data: \(error)")
        }
    }
}
