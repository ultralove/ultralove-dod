import Foundation

@Observable class FascismViewModel: LocationViewModel {
    private let fascismController = FascismController()

    var sensor: FascismSensor?
    var measurements: [Fascism] = []
    var current: Fascism?
    var timestamp: Date? = nil

    var faceplate: String {
        if let measurement = current?.value {
            return String(format: "\(GreekLetters.mathematicalBoldCapitalNu.rawValue):%.0f%@", measurement.value, measurement.unit.symbol)
        }
        else {
            return "\(GreekLetters.mathematicalItalicCapitalNu.rawValue):n/a"
        }
    }

    var maxValue: Measurement<UnitPercentage> {
        return Measurement<UnitPercentage>(value: 100.0, unit: .percent)
    }

    var minValue: Measurement<UnitPercentage> {
        return Measurement<UnitPercentage>(value: 0.0, unit: .percent)
    }

    var trend: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToLastUTCDayChange(from: Date.now) {
            if let currentRadiation = measurements.first(where: { $0.timestamp == currentDate })?.value.value {
                if let nextDate = Date.roundToLastUTCDayChange(from: Date.now.addingTimeInterval(60 * 60 * 24)) {
                    if let nextRadiation = measurements.first(where: { $0.timestamp == nextDate })?.value.value {
                        if currentRadiation > nextRadiation {
                            symbol = "arrow.down.forward.circle"
                        }
                        else if currentRadiation < nextRadiation {
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
            if let sensor = try await fascismController.refreshFascism(for: location) {
                self.sensor = sensor
                if let measurements = await Self.sanitizeMeasurements(measurements: sensor.measurements) {
                    self.measurements = measurements
                    if let current = self.measurements.max(by: { $0.timestamp < $1.timestamp }) {
                        self.current = current
                        if let forecast = await Self.forecast(data: self.measurements) {
                            self.measurements.append(contentsOf: forecast)
                        }
                    }
                    self.timestamp = sensor.timestamp
                }
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")

        }
    }

    private static func sanitizeMeasurements(measurements: [Fascism]) async -> [Fascism]? {
        var sanitized: [Fascism] = []
        var measurementQueue = Queue<Fascism>(with: measurements)
        if let minTimestamp = measurements.map({ $0.timestamp }).min() {
            if let maxTimestamp = measurements.map({ $0.timestamp }).max() {
                var currentTimestamp = minTimestamp
                var currentFascism: Fascism? = nil
                while (currentTimestamp <= maxTimestamp) && (measurementQueue.isEmpty == false) {
                    if let nextFascism = measurementQueue.first() {
                        if nextFascism.timestamp == currentTimestamp {
                            currentFascism = nextFascism
                            while measurementQueue.first()?.timestamp == currentTimestamp {
                                _ = measurementQueue.dequeue()
                            }
                        }
                    }
                    if let sanitizedFascism = currentFascism {
                        sanitized.append(Fascism(value: sanitizedFascism.value, quality: sanitizedFascism.quality, timestamp: currentTimestamp))
                    }
                    else {
                        sanitized.append(Fascism(value: Measurement<UnitPercentage>(value: 0, unit: .percent), quality: .bad, timestamp: currentTimestamp))
                    }
                    currentTimestamp = currentTimestamp.addingTimeInterval(60 * 60 * 24)
                }
            }
        }
        return sanitized
    }

    private static func forecast(data: [Fascism]?) async -> [Fascism]? {
        guard let data = data, data.count > 0 else { return nil }
        if let latest = data.max(by: { $0.timestamp < $1.timestamp }) {
            return await Self.initializeForecast(from: latest.timestamp, count: Int(Double(data.count) * 0.5))
        }
        return nil
    }

    private static func initializeForecast(from: Date, count: Int) async -> [Fascism]? {
        guard count > 0 else {
            return nil
        }
        var forecast: [Fascism] = []
        for i in 1 ... count {
//            if let timestamp = Calendar.current.date(byAdding: .day, value: i, to: from) {
            let timestamp = from.addingTimeInterval(TimeInterval(i * 60 * 60 * 24))
                forecast.append(Fascism(value: Measurement<UnitPercentage>(value: 0, unit: .percent), quality: .unknown, timestamp: timestamp))
        }
        return forecast
    }
}
