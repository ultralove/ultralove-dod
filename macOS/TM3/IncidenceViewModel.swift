import Foundation

@Observable class IncidenceViewModel: LocationViewModel {
    private let incidenceController = IncidenceController()

    var sensor: IncidenceSensor?
    var measurements: [Incidence] = []
    var current: Incidence?
    var timestamp: Date? = nil

    var faceplate: String {
        if let measurement = current?.value {
            return String(format: "\(GreekLetters.mathematicalBoldCapitalOmicron.rawValue):%.1f", measurement.value)
        }
        else {
            return "\(GreekLetters.mathematicalItalicCapitalOmicron.rawValue):n/a"
        }
    }

    var maxValue: Measurement<UnitIncidence> {
        return measurements.map({ $0.value }).max() ?? Measurement<UnitIncidence>(value: 0.0, unit: .casesper100k)
    }

    var minValue: Measurement<UnitIncidence> {
        return Measurement<UnitIncidence>(value: 0.0, unit: .casesper100k)
    }

    var trend: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToLastDayChange(from: Date.now) {
            if let currentIncidence = measurements.first(where: { $0.timestamp == currentDate })?.value {
                if let nextDate = Date.roundToLastDayChange(from: Date.now.addingTimeInterval(60 * 60 * 24)) {
                    if let nextIncidence = measurements.first(where: { $0.timestamp == nextDate })?.value {
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
            if let sensor = try await incidenceController.refreshIncidence(for: location) {
                self.sensor = sensor
                self.measurements = sensor.measurements
                if let current = Self.nowCast(data: self.measurements, alpha: 0.33) {
                    self.current = current
                    self.measurements.append(current)
                    if let forecast = Self.forcast(data: self.measurements) {
                        self.measurements.append(contentsOf: forecast)
                    }

                }
                self.timestamp = sensor.timestamp
                self.updateRegion(for: self.id, with: sensor.location)
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")
        }
    }

    private static func nowCast(data: [Incidence]?, alpha: Double) -> Incidence? {
        guard let data = data, data.count > 0, alpha >= 0.0, alpha <= 1.0 else {
            return nil
        }
        let historicalData = [Incidence](data.reversed())
        if let current = historicalData.max(by: { $0.timestamp < $1.timestamp }) {
            if let timestamp = Calendar.current.date(byAdding: .day, value: 1, to: current.timestamp) {
                let value = Self.nowCast(data: historicalData[1].value, previous: historicalData[0].value, alpha: alpha)
                return Incidence(value: value, quality: .uncertain, timestamp: timestamp)
            }
        }
        return nil
    }

    private static func nowCast(data: Measurement<UnitIncidence>, previous: Measurement<UnitIncidence>, alpha: Double) -> Measurement<UnitIncidence> {
        let value = alpha * data.value + (1 - alpha) * previous.value
        return Measurement<UnitIncidence>(value: value, unit: .casesper100k)
    }

    private static func forcast(data: [Incidence]?) -> [Incidence]? {
        guard let historicalData = data, historicalData.count > 0 else {
            return nil
        }
        var forecast: [Incidence] = []
        if let max = historicalData.max(by: { $0.timestamp < $1.timestamp }) {
            for i in 0 ..< historicalData.count {
                if let timestamp = Calendar.current.date(byAdding: .day, value: i + 1, to: max.timestamp) {
                    let value = Measurement<UnitIncidence>(value: 0.0, unit: .casesper100k)
                    forecast.append(Incidence(value: value, quality: .unknown, timestamp: timestamp))
                }
            }
        }
        return forecast
    }
}
