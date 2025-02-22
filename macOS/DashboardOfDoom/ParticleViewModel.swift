import SwiftUI

@Observable class ParticleViewModel: LocationViewModel {
    private let particleController = ParticleController()

    var sensor: ParticleSensor?
    var measurements: [ParticleSelector: [Particle]] = [:]
    var current: [ParticleSelector: Particle] = [:]
    var timestamp: Date? = nil

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

    func faceplate(selector: ParticleSelector) -> String {
        guard let measurement = current[selector]?.value else {
            return "\(GreekLetters.mathematicalItalicCapitalRho.rawValue)\(GreekLetters.mathematicalItalicCapitalMu.rawValue)\u{2081}\u{2080}: n/a"
        }
        if selector == .pm10 {
            return String(format: "\(GreekLetters.mathematicalBoldCapitalRho.rawValue)\(GreekLetters.mathematicalBoldCapitalMu.rawValue)\u{2081}\u{2080}: %.0f%@", measurement.value, measurement.unit.symbol)
        }
        else if selector == .pm25 {
            return String(format: "\(GreekLetters.mathematicalBoldCapitalRho.rawValue)\(GreekLetters.mathematicalBoldCapitalMu.rawValue)\u{2082}\u{2085}: %.0f%@", measurement.value, measurement.unit.symbol)
        }
        else if selector == .o3 {
            return String(format: "\(GreekLetters.mathematicalBoldCapitalOmicron.rawValue)\u{2083}:   %.0f%@", measurement.value, measurement.unit.symbol)
        }
        else if selector == .no2 {
            return String(format: "\(GreekLetters.mathematicalBoldCapitalNu.rawValue)\(GreekLetters.mathematicalBoldCapitalOmicron.rawValue)\u{2082}:  %.0f%@", measurement.value, measurement.unit.symbol)
        }
        return "\(GreekLetters.mathematicalItalicCapitalRho.rawValue)\(GreekLetters.mathematicalItalicCapitalMu.rawValue)\u{2081}\u{2080}: n/a"
    }

    func trend(selector: ParticleSelector) -> String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToPreviousHour(from: Date.now) {
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

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await particleController.refreshParticles(for: location) {
                self.sensor = sensor
                let measurements = sensor.measurements
                self.measurements = await self.interpolateMeasurements(measurements: measurements)
                self.current = await self.updateCurrent(measurements: self.measurements)
                self.timestamp = sensor.timestamp
                MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
            }
        }
        catch {
            print("Error refreshing data: \(error)")
        }
    }

    private func updateCurrent(measurements: [ParticleSelector: [Particle]]) async -> [ParticleSelector: Particle] {
        var currentMeasurements: [ParticleSelector: Particle] = [:]
        for (selector, forecast) in measurements {
            if let lastKnownGood = findLastKnownGoodMeasurement(measurements: forecast) {
                if let current = forecast.last(where: { $0.timestamp == Date.roundToPreviousHour(from: lastKnownGood.timestamp) }) {
                    currentMeasurements[selector] = current
                }
            }
        }
        return currentMeasurements
    }

    private func findLastKnownGoodMeasurement(measurements: [Particle]) -> Particle? {
        return measurements.last(where: { ($0.timestamp <= Date.now) && ($0.quality == .good) })
    }

    private func interpolateMeasurements(measurements: [ParticleSelector: [Particle]]) async -> [ParticleSelector: [Particle]] {
        var interpolatedMeasurements: [ParticleSelector: [Particle]] = [:]
        for (selector, measurement) in measurements {
            interpolatedMeasurements[selector] = self.interpolateMeasurement(measurements: measurement)
        }
        return interpolatedMeasurements
    }

    private func interpolateMeasurement(measurements: [Particle]) -> [Particle] {
        var interpolatedMeasurement: [Particle] = []
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
                                Particle(
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

