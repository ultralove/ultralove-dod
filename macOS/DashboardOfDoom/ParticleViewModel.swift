import SwiftUI

@Observable class ParticleViewModel: Identifiable, SubscriberProtocol {
    private let particleController = ParticleController()

    let id = UUID()
    var sensor: ParticleSensor?
    var measurements: [ParticleSelector: [ProcessValue<Dimension>]] = [:]
    var timestamp: Date? = nil

    init() {
        let subscriptionManager = SubscriptionManager.shared
        subscriptionManager.addSubscription(delegate: self, timeout: 30)  // 30 minutes
    }

    func hasMeasurements(selector: ParticleSelector) -> Bool {
        return self.measurements[selector] != nil
    }

    func maxValue(selector: ParticleSelector) -> Measurement<Dimension> {
        if let measurements = self.measurements[selector] {
            if let measurement = measurements.first {
                if let value = measurements.max(by: { $0.value.value < $1.value.value })?.value.value {
                    return Measurement(value: value, unit: measurement.value.unit)
                }
            }
        }
        return Measurement(value: 0.0, unit: UnitPercentage.percent)
    }

    func minValue(selector: ParticleSelector) -> Measurement<Dimension> {
        if let measurements = self.measurements[selector] {
            if let measurement = self.measurements[selector]?.first {
                if let value = measurements.min(by: { $0.value.value < $1.value.value })?.value.value {
                    return Measurement(value: value, unit: measurement.value.unit)
                }
            }
        }
        return Measurement(value: 0.0, unit: UnitPercentage.percent)
    }

    func current(selector: ParticleSelector) -> ProcessValue<Dimension>? {
        guard let measurement = measurements[selector] else {
            return nil
        }
        if let lastKnownGood = findLastKnownGoodMeasurement(measurements: measurement) {
            if let current = measurement.last(where: { $0.timestamp == Date.round(from: lastKnownGood.timestamp, strategy: .previousHour) }) {
                return current
            }
        }
        return nil
    }

    func faceplate(selector: ParticleSelector) -> String {
        guard let measurement = current(selector: selector)?.value else {
            return
                "\(MathematicalSymbols.mathematicalItalicCapitalRho.rawValue)\(MathematicalSymbols.mathematicalItalicCapitalMu.rawValue)\u{2081}\u{2080}:n/a"
        }
        if selector == .pm10 {
            return String(
                format:
                    "\(MathematicalSymbols.mathematicalBoldCapitalRho.rawValue)\(MathematicalSymbols.mathematicalBoldCapitalMu.rawValue)\u{2081}\u{2080}: %.0f%@",
                measurement.value, measurement.unit.symbol)
        }
        else if selector == .pm25 {
            return String(
                format:
                    "\(MathematicalSymbols.mathematicalBoldCapitalRho.rawValue)\(MathematicalSymbols.mathematicalBoldCapitalMu.rawValue)\u{2082}\u{2085}: %.0f%@",
                measurement.value, measurement.unit.symbol)
        }
        else if selector == .o3 {
            return String(
                format: "\(MathematicalSymbols.mathematicalBoldCapitalOmicron.rawValue)\u{2083}: %.0f%@", measurement.value,
                measurement.unit.symbol)
        }
        else if selector == .no2 {
            return String(
                format:
                    "\(MathematicalSymbols.mathematicalBoldCapitalNu.rawValue)\(MathematicalSymbols.mathematicalBoldCapitalOmicron.rawValue)\u{2082}: %.0f%@",
                measurement.value, measurement.unit.symbol)
        }
        return
            "\(MathematicalSymbols.mathematicalItalicCapitalRho.rawValue)\(MathematicalSymbols.mathematicalItalicCapitalMu.rawValue)\u{2081}\u{2080}: n/a"
    }

    func faceplate() -> String {
        var found: ParticleSelector = .pm10
        for selector in ParticleSelector.allCases where self.hasMeasurements(selector: selector) {
            found = selector
            break
        }
        return self.faceplate(selector: found)
    }

    var icon: String {
        if let customData = sensor?.customData {
            if let icon = customData["icon"] as? String {
                return icon
            }
        }
        return "questionmark.circle"
    }

    func trend(selector: ParticleSelector) -> String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.round(from: Date.now, strategy: .previousHour) {
            if let currentForecast = self.measurements[selector]?.last(where: { $0.timestamp == currentDate }) {
                if let previousForecast = self.measurements[selector]?.last(where: { $0.timestamp < currentForecast.timestamp }) {
                    let currentValue = currentForecast.value.value
                    let previousValue = previousForecast.value.value
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
        }
        return symbol
    }

    func refreshData(location: Location) async -> Void {
        if let sensor = await particleController.refreshParticles(for: location) {
            self.sensor = sensor
            let measurements = self.interpolateMeasurements(measurements: sensor.measurements)
            await self.synchronizeData(sensor: sensor, measurements: measurements)
        }
    }

    @MainActor func synchronizeData(sensor: ParticleSensor, measurements: [ParticleSelector: [ProcessValue<Dimension>]]) async -> Void {
        self.sensor = sensor
        self.measurements = measurements
        self.timestamp = sensor.timestamp
        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }

    private func findLastKnownGoodMeasurement(measurements: [ProcessValue<Dimension>]) -> ProcessValue<Dimension>? {
        return measurements.last(where: { ($0.timestamp <= Date.now) && ($0.quality == .good) })
    }

    private func interpolateMeasurements(measurements: [ParticleSelector: [ProcessValue<Dimension>]]) -> [ParticleSelector: [ProcessValue<Dimension>]] {
        var interpolatedMeasurements: [ParticleSelector: [ProcessValue<Dimension>]] = [:]
        for (selector, measurement) in measurements {
            interpolatedMeasurements[selector] = self.interpolateMeasurement(measurements: measurement)
        }
        return interpolatedMeasurements
    }

    private func interpolateMeasurement(measurements: [ProcessValue<Dimension>]) -> [ProcessValue<Dimension>] {
        var interpolatedMeasurement: [ProcessValue<Dimension>] = []
        if let start = measurements.first?.timestamp, let end = measurements.last?.timestamp {
            let unit = measurements[0].value.unit
            var current = start
            if var last = measurements.first {
                while current <= end {
                    if let match = measurements.first(where: { $0.timestamp == current }) {
                        last = match
                        interpolatedMeasurement.append(match)
                    }
                    else {
                        interpolatedMeasurement
                            .append(
                                ProcessValue<Dimension>(
                                    value: Measurement(value: last.value.value, unit: unit), quality: .uncertain,
                                    timestamp: current))
                    }
                    current = current.addingTimeInterval(60 * 60)
                }
            }
        }
        return interpolatedMeasurement
    }
}
