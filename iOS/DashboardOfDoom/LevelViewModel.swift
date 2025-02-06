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
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")

        }
    }

    private static func forecast(data: [Level]?) async -> [Level]? {
        guard let data = data, data.count > 0 else { return nil }
        if let latest = data.max(by: { $0.timestamp < $1.timestamp }) {
            return await Self.initializeForecast(from: latest.timestamp, count: Int(Double(data.count) * 0.33))
        }
        return nil
    }

    private static func initializeForecast(from: Date, count: Int) async -> [Level]? {
        guard count > 0 else {
            return nil
        }
        var forecast: [Level] = []
        for i in 1 ... count {
            if let timestamp = Calendar.current.date(byAdding: .minute, value: i * 15, to: from) {
                forecast.append(Level(value: Measurement<UnitLength>(value: 0, unit: .meters), quality: .unknown, timestamp: timestamp))
            }
        }
        return forecast
    }
}
