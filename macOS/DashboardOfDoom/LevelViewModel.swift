import SwiftUI

@Observable class LevelViewModel: LocationViewModel {
    private let levelController = LevelController()

    var sensor: LevelSensor?
    var measurements: [Level] = []
    var timestamp: Date? = nil

    var faceplate: String {
        guard let measurement = current?.value else {
            return "\(GreekLetters.levelLeft.rawValue)n/a\(GreekLetters.levelRight.rawValue)"
        }
        return String(
            format: "\(GreekLetters.levelLeft.rawValue)%.2f%@\(GreekLetters.levelRight.rawValue)",
            measurement.value, measurement.unit.symbol)
    }

    var maxValue: Measurement<UnitLength> {
        return measurements.map({ $0.value }).max() ?? Measurement<UnitLength>(value: 0, unit: .meters)
    }

    var minValue: Measurement<UnitLength> {
        return Measurement<UnitLength>(value: 0, unit: .meters)
    }

    var current: Level? {
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

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await levelController.refreshLevel(for: location) {
                self.sensor = sensor
                self.measurements = sensor.measurements
                if let forecast = await Self.forecast(data: self.measurements) {
                    self.measurements.append(contentsOf: forecast)
                }
                self.timestamp = sensor.timestamp
                MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")

        }
    }

    private static func forecast(data: [Level]?) async -> [Level]? {
        var forecast: [Level]? = nil
        guard let historicalData = data, historicalData.count > 0 else {
            return nil
        }
        let unit = historicalData[0].value.unit
        let historicalDataPoints = historicalData.map { incidence in
            TimeSeriesPoint(timestamp: incidence.timestamp, value: incidence.value.value)
        }
        let predictor = ARIMAPredictor(parameters: ARIMAParameters(p: 2, d: 1, q: 1), interval: .quarterHourly)
        do {
            try predictor.addData(historicalDataPoints)
            let prediction = try predictor.forecast(duration: 36 * 3600) // 1.5 days
            forecast = prediction.forecasts.map { forecast in
                Level(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
            }
        }
        catch {
            print("Forecasting error: \(error)")
        }
        return forecast
    }
}
