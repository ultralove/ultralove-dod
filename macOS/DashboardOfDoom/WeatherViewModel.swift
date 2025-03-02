import CoreLocation
import MapKit
import SwiftUI

@Observable class WeatherViewModel: Identifiable, SubscriberProtocol {
    private let weatherController = WeatherController()

    let id = UUID()
    var sensor: WeatherSensor?
    var measurements: [WeatherSelector: ProcessValue<Dimension>] = [:]
    var timestamp: Date? = nil

    init() {
        let subscriptionManager = SubscriptionManager.shared
        subscriptionManager.addSubscription(id: id, delegate: self, timeout: 5)  // 5 minutes
    }

    func faceplate(selector: WeatherSelector) -> String {
        guard let measurement = measurements[selector]?.value else {
            return String(
                format:
                    "\(MathematicalSymbols.mathematicalBoldCapitalTau.rawValue): n/a")
        }
        return String(
            format:
                "\(MathematicalSymbols.mathematicalBoldCapitalTau.rawValue): %.1f%@", measurement.value, measurement.unit.symbol)
    }

    var icon: String {
        if let customData = sensor?.customData {
            if let icon = customData["icon"] as? String {
                return icon
            }
        }
        return "questionmark.circle"
    }

    @MainActor func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await weatherController.refreshWeather(for: location) {
                self.sensor = sensor
                self.measurements = sensor.measurements
                self.timestamp = sensor.timestamp
                MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
            }
        }
        catch {
            trace.error("Error refreshing data: %@", error.localizedDescription)
        }
    }
}
