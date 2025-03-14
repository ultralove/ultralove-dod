import SwiftUI

@Observable class RadiationViewModel: Identifiable, ProcessSubscriberProtocol {
    private let radiationController = RadiationController()

    let id = UUID()
    var sensor: ProcessSensor?
    var measurements: [ProcessSelector: [ProcessValue<Dimension>]] = [:]
    var timestamp: Date? = nil

    var current: [ProcessSelector: ProcessValue<Dimension>] = [:]
    var faceplate: [ProcessSelector: String] = [:]
    var range: [ProcessSelector: ClosedRange<Double>] = [:]
    var trend: [ProcessSelector: String] = [:]

    init() {
        let subscriptionManager = ProcessManager.shared
        subscriptionManager.addSubscription(delegate: self, timeout: 30)  // 30 minutes
    }

    var icon: String {
        if let customData = sensor?.customData {
            if let icon = customData["icon"] as? String {
                return icon
            }
        }
        return "questionmark.circle"
    }

    func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await radiationController.refreshData(for: location) {
                await self.synchronizeData(sensor: sensor)
            }
        }
        catch {
            trace.error("Error refreshing data: %@", error.localizedDescription)
        }
    }

    @MainActor func synchronizeData(sensor: ProcessSensor) async -> Void {
        self.sensor = sensor
        self.measurements = sensor.measurements
        self.timestamp = sensor.timestamp

        self.current = Self.renderCurrent(measurements: self.measurements)
        self.faceplate = Self.renderFaceplate(current: self.current)
        self.range = Self.renderRange(measurements: self.measurements)
        self.trend = Self.renderTrend(measurements: self.measurements)

        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }

    private static func renderCurrent(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) -> [ProcessSelector: ProcessValue<Dimension>] {
        var current: [ProcessSelector: ProcessValue<Dimension>] = [:]
        for(selector, values) in measurements {
            current[selector] = values.last(where: { ($0.timestamp <= Date.now) && ($0.quality == .good) })
        }
        return current
    }

    private static func renderFaceplate(current: [ProcessSelector: ProcessValue<Dimension>]) -> [ProcessSelector: String] {
        var faceplate: [ProcessSelector: String] = [:]
        for(selector, current) in current {
            switch selector {
                case .radiation:
                    faceplate[selector] = String(
                        format: "\(MathematicalSymbols.mathematicalBoldCapitalGamma.rawValue): %.3f%@", current.value.value, current.value.unit.symbol)
                default:
                    faceplate[selector] = "\(MathematicalSymbols.mathematicalItalicCapitalGamma.rawValue):n/a"
            }
        }
        return faceplate
    }

    private static func renderRange(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) -> [ProcessSelector: ClosedRange<Double>] {
        var scale: [ProcessSelector: ClosedRange<Double>] = [:]
        for(selector, values) in measurements {
            scale[selector] = 0.0...(values.map({ $0.value }).max()?.value ?? 0.0) * 1.67
        }
        return scale
    }

    private static func renderTrend(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) -> [ProcessSelector: String] {
        var trend: [ProcessSelector: String] = [:]
        for(selector, values) in measurements {
            trend[selector] = "questionmark.circle"
            if let current = values.last(where: { ($0.timestamp <= Date.now) && ($0.quality == .good) }) {
                if let past = values.last(where: { $0.timestamp < current.timestamp }) {
                    if past.value < current.value {
                        print("RADIATION: \(past.timestamp):\(past.value) < \(current.timestamp):\(current.value) -> UP")
                        trend[selector] = "arrow.up.forward.circle"
                    }
                    else if past.value > current.value {
                        print("RADIATION: \(past.timestamp):\(past.value) > \(current.timestamp):\(current.value) -> DOWN")
                        trend[selector] = "arrow.down.forward.circle"
                    }
                    else {
                        print("RADIATION: \(past.timestamp):\(past.value) = \(current.timestamp):\(current.value) -> UNCHANGED")
                        trend[selector] = "arrow.right.circle"
                    }
                }
            }
        }
        return trend
    }
}
