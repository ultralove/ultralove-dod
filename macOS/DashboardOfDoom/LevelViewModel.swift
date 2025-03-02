import SwiftUI

@Observable class LevelViewModel: Identifiable, SubscriberProtocol {
    private let levelController = LevelController()

    let id = UUID()
    var sensor: LevelSensor?
    var measurements: [ProcessValue<Dimension>] = []
    var timestamp: Date? = nil

    init() {
        let subscriptionManager = SubscriptionManager.shared
        subscriptionManager.addSubscription(id: id, delegate: self, timeout: 15)  // 15 minutes
    }

    var faceplate: String {
        guard let measurement = current?.value else {
            //            return "\(GreekLetters.levelLeft.rawValue)n/a\(GreekLetters.levelRight.rawValue)"
            return "\(MathematicalSymbols.mathematicalItalicCapitalEta.rawValue):n/a"
        }
        return String(
            //            format: "\(GreekLetters.levelLeft.rawValue)%.2f%@\(GreekLetters.levelRight.rawValue)",
            format: "\(MathematicalSymbols.mathematicalBoldCapitalEta.rawValue): %.2f%@", measurement.value, measurement.unit.symbol)
    }

    var icon: String {
        if let customData = sensor?.customData {
            if let icon = customData["icon"] as? String {
                return icon
            }
        }
        return "questionmark.circle"
    }

    var maxValue: Measurement<Dimension> {
        return measurements.map({ $0.value }).max() ?? Measurement<Dimension>(value: 0, unit: UnitLength.meters)
    }

    var minValue: Measurement<Dimension> {
        return Measurement<Dimension>(value: 0, unit: UnitLength.meters)
    }

    var current: ProcessValue<Dimension>? {
        return measurements.last(where: { ($0.timestamp <= Date.now) && ($0.quality == .good) })
    }

    var trend: String {
        var symbol = "questionmark.circle"
        if let currentLevel = self.current {
            if let previousLevel = measurements.last(where: { $0.timestamp < currentLevel.timestamp }) {
                let currentValue = currentLevel.value
                let previousValue = previousLevel.value
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
            if let sensor = try await levelController.refreshLevel(for: location) {
                await self.synchronizeData(sensor: sensor)
            }
        }
        catch {
            trace.error("Error refreshing data: %@", error.localizedDescription)
        }
    }

    @MainActor func synchronizeData(sensor: LevelSensor) async -> Void {
        self.sensor = sensor
        self.measurements = sensor.measurements
        self.timestamp = sensor.timestamp
        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }
}
