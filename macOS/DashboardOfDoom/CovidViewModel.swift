import Foundation

@Observable class CovidViewModel: ProcessPresenter, PresenterProtocol, ProcessSubscriberProtocol {
    private let incidenceController = CovidController()

    override init() {
        super.init()
        let subscriptionManager = ProcessManager.shared
        subscriptionManager.addSubscription(delegate: self, timeout: 360)  // 6  hours
    }

    func faceplate(selector: ProcessSelector) -> String {
        let invalid = "\(MathematicalSymbols.mathematicalItalicCapitalOmicron.rawValue):n/a"
        if let current = self.current(selector: selector)?.value {
            switch selector {
                case .covid:
                    return String(
                        format: "\(MathematicalSymbols.mathematicalBoldCapitalOmicron.rawValue)%@: %.1f",
                        current.unit.symbol, current.value)
                default:
                    return invalid
            }
        }
        return invalid
    }

    func maxValue(selector: ProcessSelector) -> Double {
        if let measurements = self.measurements[selector] {
            return measurements.map({ $0.value }).max()?.value ?? 0.0
        }
        else {
            return 0.0
        }
    }

    func minValue(selector: ProcessSelector) -> Double {
        return 0.0
    }

    func current(selector: ProcessSelector) -> ProcessValue<Dimension>? {
        if let measurements = self.measurements[selector] {
            return measurements.last(where: { ($0.timestamp <= Date.now) && (($0.quality == .good) || ($0.quality == .uncertain)) })
        }
        else {
            return nil
        }
    }

    func trend(selector: ProcessSelector) -> String {
        var symbol = "questionmark.circle"
        if let current = self.current(selector: selector), let measurements = self.measurements[selector] {
            if let previous = measurements.last(where: { $0.timestamp < current.timestamp }) {
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
            if let sensor = try await incidenceController.refreshData(for: location) {
                await synchronizeData(sensor: sensor)
            }
        }
        catch {
            trace.error("Error refreshing data: %@", error.localizedDescription)
        }
    }

    @MainActor func synchronizeData(sensor: ProcessSensor) async {
        self.sensor = sensor
        self.measurements = sensor.measurements
        self.timestamp = sensor.timestamp
        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }
}
