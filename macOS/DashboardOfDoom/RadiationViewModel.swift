import SwiftUI

@Observable class RadiationViewModel: Identifiable, SubscriptionManagerDelegate {
    private let radiationController = RadiationController()

    let id = UUID()
    var sensor: RadiationSensor?
    var measurements: [Radiation] = []
    var timestamp: Date? = nil

    init() {
        let subscriptionManager = SubscriptionManager.shared
        subscriptionManager.addSubscription(id: id, delegate: self, timeout: 30)  // 30 minutes
    }

    var faceplate: String {
        guard let measurement = current?.value else {
            return "\(GreekLetters.mathematicalItalicCapitalGamma.rawValue): n/a"
        }
        return String(format: "\(GreekLetters.mathematicalBoldCapitalGamma.rawValue): %.3f%@", measurement.value, measurement.unit.symbol)
    }

    var maxValue: Measurement<UnitRadiation> {
        return measurements.map({ $0.value }).max() ?? Measurement<UnitRadiation>(value: 0.0, unit: .microsieverts)
    }

    var minValue: Measurement<UnitRadiation> {
        return Measurement<UnitRadiation>(value: 0.0, unit: .microsieverts)
    }

    var current: Radiation? {
        return measurements.last(where: { ($0.timestamp <= Date.now) && ($0.quality == .good) } )
    }

    var trend: String {
        var symbol = "questionmark.circle"
        if let currentRadiation =  self.current {
            if let previousRadiation = measurements.last(where: { $0.timestamp < currentRadiation.timestamp }) {
                let currentValue = currentRadiation.value
                let previousValue = previousRadiation.value
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
        return symbol
    }

    func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await radiationController.refreshRadiation(for: location) {
                await self.synchronizeData(sensor: sensor)
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")

        }
    }

    @MainActor func synchronizeData(sensor: RadiationSensor) async -> Void {
        self.sensor = sensor
        self.measurements = sensor.measurements.sorted(by: { $0.timestamp < $1.timestamp })
        self.timestamp = sensor.timestamp
        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }
}
