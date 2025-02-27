import SwiftUI

@Observable class ForecastViewModel: Identifiable, SubscriptionManagerDelegate {
    private let forecastController = ForecastController()

    let id = UUID()
    var sensor: ForecastSensor?
    var measurements: [ForecastSelector: [Forecast]] = [:]
    var timestamp: Date? = nil

    init() {
        let subscriptionManager = SubscriptionManager.shared
        subscriptionManager.addSubscription(id: id, delegate: self, timeout: 5)  // 5 minutes
    }

    func maxValue(selector: ForecastSelector) -> Measurement<Dimension> {
        if let measurements = self.measurements[selector] {
            if let measurement = measurements.first {
                if measurement.value.unit is UnitTemperature {
                    return Measurement(value: 47.0, unit: measurement.value.unit)
                }
                else if measurement.value.unit is UnitPercentage {
                    return Measurement(value: 100.0, unit: measurement.value.unit)
                }
                else {
                    if let value = measurements.max(by: { $0.value.value < $1.value.value })?.value.value {
                        return Measurement(value: value, unit: measurement.value.unit)
                    }
                }
            }
        }
        return Measurement(value: 100.0, unit: UnitPercentage.percent)
    }

    func minValue(selector: ForecastSelector) -> Measurement<Dimension> {
        if let measurements = self.measurements[selector] {
            if let measurement = self.measurements[selector]?.first {
                if measurement.value.unit is UnitTemperature {
                    return Measurement(value: -20.0, unit: measurement.value.unit)
                }
                else if measurement.value.unit is UnitPercentage {
                    return Measurement(value: 0.0, unit: measurement.value.unit)
                }
                else {
                    if let value = measurements.min(by: { $0.value.value < $1.value.value })?.value.value {
                        return Measurement(value: value, unit: measurement.value.unit)
                    }
                }
            }
        }
        return Measurement(value: 0.0, unit: UnitPercentage.percent)
    }

    func current(selector: ForecastSelector) -> Forecast? {
        var current: Forecast? = nil
        if let measurement = measurements[selector] {
            current = measurement.last(where: { $0.timestamp == Date.roundToNextHour(from: Date.now) })
        }
        return current
    }

    func trend(selector: ForecastSelector) -> String {
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

    func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await forecastController.refreshForecast(for: location) {
                await self.synchronizeData(
                    sensor: ForecastSensor(
                        id: sensor.id, placemark: sensor.placemark, location: sensor.location,
                        measurements: await self.sanitizeForecast(measurements: sensor.measurements), timestamp: sensor.timestamp))
            }
        }
        catch {
            print("Error refreshing data: \(error)")
        }
    }

    @MainActor func synchronizeData(sensor: ForecastSensor) async -> Void {
        self.sensor = sensor
        self.measurements = await self.sanitizeForecast(measurements: sensor.measurements)
        self.timestamp = sensor.timestamp
        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }

    private func sanitizeForecast(measurements: [ForecastSelector: [Forecast]]) async -> [ForecastSelector: [Forecast]] {
        var sanitizedMeasurements: [ForecastSelector: [Forecast]] = [:]
        for (selector, forecast) in measurements {
            var sanitizedForecast: [Forecast] = []
            for value in forecast {
                let quality = (value.timestamp < Date.now) ? ProcessValueQuality.good : ProcessValueQuality.uncertain
                sanitizedForecast.append(
                    Forecast(
                        value: Measurement(value: value.value.value, unit: value.value.unit), quality: quality, timestamp: value.timestamp))
            }
            sanitizedMeasurements[selector] = sanitizedForecast
        }
        return sanitizedMeasurements
    }
}
