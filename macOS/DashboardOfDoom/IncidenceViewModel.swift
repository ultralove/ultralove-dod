import Foundation

@Observable class IncidenceViewModel: Identifiable, SubscriptionManagerDelegate {
    private let incidenceController = IncidenceController()

    let id = UUID()
    var sensor: IncidenceSensor?
    var measurements: [IncidenceSelector: [ProcessValue<Dimension>]] = [:]
    var timestamp: Date? = nil

    init() {
        let subscriptionManager = SubscriptionManager.shared
        subscriptionManager.addSubscription(id: id, delegate: self, timeout: 360)  // 6  hours
    }

    func faceplate(selector: IncidenceSelector) -> String {
        switch selector {
            case .incidence:
                if let measurement = self.current(selector: selector)?.value {
                    return String(
                        format: "\(GreekLetters.mathematicalBoldCapitalOmicron.rawValue)%@: %.1f", measurement.unit.symbol, measurement.value)
                }
                else {
                    return "\(GreekLetters.mathematicalItalicCapitalOmicron.rawValue): n/a"
                }
            default:
                if let measurement = self.current(selector: selector)?.value {
                    return String(
                        format: "\(GreekLetters.mathematicalBoldCapitalRho.rawValue)%@: %.1f", measurement.unit.symbol, measurement.value)
                }
                else {
                    return "\(GreekLetters.mathematicalItalicCapitalRho.rawValue): n/a"
                }
        }
    }

    func maxValue(selector: IncidenceSelector) -> Measurement<Dimension> {
        switch selector {
            case .incidence:
                return measurements[selector]?.map({ $0.value }).max() ?? Measurement<Dimension>(value: 0.0, unit: UnitIncidence.casesPer100k)
            default:
                return measurements[selector]?.map({ $0.value }).max() ?? Measurement<Dimension>(value: 0.0, unit: UnitPopulation.people)
        }
    }

    func minValue(selector: IncidenceSelector) -> Measurement<Dimension> {
        switch selector {
            case .incidence:
                return Measurement<Dimension>(value: 0.0, unit: UnitIncidence.casesPer100k)
            default:
                return Measurement<Dimension>(value: 0.0, unit: UnitPopulation.people)
        }
    }

    func current(selector: IncidenceSelector) -> ProcessValue<Dimension>? {
        return measurements[selector]?.last(where: { ($0.timestamp <= Date.now) && (($0.quality == .good) || ($0.quality == .uncertain)) })
    }

    func trend(selector: IncidenceSelector) -> String {
        var symbol = "questionmark.circle"
        if let current = self.current(selector: selector) {
            if let previous = measurements[selector]?.last(where: { $0.timestamp < current.timestamp }) {
                if current.value < previous.value {
                    symbol = "arrow.down.forward.circle"
                }
                else if current.value > previous.value {
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
        //        self.measurements = sensor.measurements.sorted(by: { $0.timestamp < $1.timestamp })
        self.measurements = sensor.measurements
        self.timestamp = sensor.timestamp
        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }
}
