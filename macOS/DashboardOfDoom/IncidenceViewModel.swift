import Foundation

@Observable class IncidenceViewModel: Identifiable, SubscriptionManagerDelegate {
    private let incidenceController = IncidenceController()

    let id = UUID()
    var sensor: IncidenceSensor?
    var measurements: [Incidence] = []
    var timestamp: Date? = nil

    init() {
        let subscriptionManager = SubscriptionManager.shared
        subscriptionManager.addSubscription(id: id, delegate: self, timeout: 360)  // 6  hours
    }

    var faceplate: String {
        guard let measurement = current?.value else {
            return "\(GreekLetters.mathematicalItalicCapitalOmicron.rawValue): n/a"
        }
        return String(format: "\(GreekLetters.mathematicalBoldCapitalOmicron.rawValue)%@: %.1f", measurement.unit.symbol, measurement.value)
    }

    var maxValue: Measurement<UnitIncidence> {
        return measurements.map({ $0.value }).max() ?? Measurement<UnitIncidence>(value: 0.0, unit: .casesPer100k)
    }

    var minValue: Measurement<UnitIncidence> {
        return Measurement<UnitIncidence>(value: 0.0, unit: .casesPer100k)
    }

    var current: Incidence? {
        return measurements.last(where: { ($0.timestamp <= Date.now) && (($0.quality == .good) || ($0.quality == .uncertain)) })
    }

    var trend: String {
        var symbol = "questionmark.circle"
        if let currentIncidence = self.current {
            if let nextIncidence = measurements.last(where: { $0.timestamp < currentIncidence.timestamp }) {
                let currentValue = currentIncidence.value
                let previousValue = nextIncidence.value
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
            if let sensor = try await incidenceController.refreshIncidence(for: location) {
                await synchronizeData(sensor: sensor)
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")
        }
    }

    @MainActor func synchronizeData(sensor: IncidenceSensor) async {
        self.sensor = sensor
        self.measurements = sensor.measurements.sorted(by: { $0.timestamp < $1.timestamp })
        self.timestamp = sensor.timestamp
        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }
}
