import CoreLocation
import MapKit
import SwiftUI

@Observable class WeatherViewModel: Identifiable, SubscriptionManagerDelegate {
    private let weatherController = WeatherController()

    var actualTemperature: Measurement<UnitTemperature>?
    var apparentTemperature: Measurement<UnitTemperature>?

    let id = UUID()
    var sensor: WeatherSensor?
    var symbol: String = "questionmark.circle"
    var timestamp: Date? = nil

    init() {
        let subscriptionManager = SubscriptionManager.shared
        subscriptionManager.addSubscription(id: id, delegate: self, timeout: 5)  // 5 minutes
    }

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

    @MainActor func refreshData(location: Location) async -> Void {
        print("\(Date.now): Weather: Refreshing data for \(location)")
        do {
            if let sensor = try await weatherController.refreshWeather(for: location) {
                self.actualTemperature = sensor.measurements.temperature
                self.apparentTemperature = sensor.measurements.apparentTemperature
                self.symbol = sensor.measurements.symbol
                self.sensor = sensor
                self.timestamp = sensor.timestamp
                MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
            }
        }
        catch {
            print("Error refreshing data: \(error)")
        }
    }
}
