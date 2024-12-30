import CoreLocation
import SwiftUI

@Observable class WeatherViewModel: LocationViewModel {
    @AppStorage("showApparentTemperature") var showApparentTemperature

    private let weatherController = WeatherController()

    var actualTemperature: Measurement<UnitTemperature>?
    var apparentTemperature: Measurement<UnitTemperature>?
    var conditionsSymbol: String = "questionmark.circle"
    var timestamp: Date? = nil

    var faceplate: String {
        if let temperature = self.temperature?.value, let symbol = self.temperature?.unit.symbol {
            return String(format: "%.1f%@", temperature, symbol)
        }
        return "n/a"
    }

     var temperature: Measurement<UnitTemperature>? {
//        self.showApparentTemperature = UserDefaults.standard.bool(forKey: "showApparentTemperature")
//        if showApparentTemperature == true {
//            return apparentTemperature
//        }
//        else {
            return actualTemperature
//        }
    }

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
            self.timestamp = nil
            if let weatherSensor = try await weatherController.refreshWeather(for: location) {
                self.actualTemperature = weatherSensor.weather.temperature
                self.apparentTemperature = weatherSensor.weather.apparentTemperature
                self.conditionsSymbol = weatherSensor.weather.conditionsSymbol
                self.timestamp = weatherSensor.timestamp
            }
        }
        catch {
            print("Error refreshing data: \(error)")
        }
    }
}
