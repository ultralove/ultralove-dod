import SwiftUI

@Observable class LevelViewModel: LocationViewModel {
    private let levelController = LevelController()

    var sensor: LevelSensor?
    var measurements: [Level] = []
    var current: Level?

    var maxLevel: Double {
        return measurements.map({ $0.value.value }).max() ?? 0.0
    }

    var trendSymbol: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToLastDayChange(from: Date.now) {
            if let currentIncidence = measurements.first(where: { $0.timestamp == currentDate })?.value.value {
                if let nextDate = Date.roundToLastDayChange(from: Date.now.addingTimeInterval(60 * 60 * 24)) {
                    if let nextIncidence = measurements.first(where: { $0.timestamp == nextDate })?.value.value {
                        if currentIncidence > nextIncidence {
                            symbol = "arrow.down.forward.circle"
                        }
                        else if currentIncidence < nextIncidence {
                            symbol = "arrow.up.forward.circle"
                        }
                        else {
                            symbol = "arrow.right.circle"
                        }
                    }
                }
            }
        }
        return symbol
    }

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
//            self.timestamp = nil
            if let sensor = try await levelController.refreshLevel(for: location) {
                self.sensor = sensor
                self.measurements = sensor.measurements
                if let current = self.measurements.max(by: { $0.timestamp < $1.timestamp }) {
                    self.current = current
                    if let forecast = await Self.forecast(data: self.measurements) {
                        self.measurements.append(contentsOf: forecast)
                    }
                }
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")

        }
    }

    private static func forecast(data: [Level]?) async -> [Level]? {
        guard let data = data, data.count > 0 else { return nil }
        if let latest = data.max(by: { $0.timestamp < $1.timestamp }) {
            return await Self.initializeForecast(from: latest.timestamp, count: data.count)
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
