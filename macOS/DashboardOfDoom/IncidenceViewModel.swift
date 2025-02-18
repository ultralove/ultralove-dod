import Foundation

@Observable class IncidenceViewModel: LocationViewModel {
    private let incidenceController = IncidenceController()

    var sensor: IncidenceSensor?
    var measurements: [Incidence] = []
    var timestamp: Date? = nil

    var faceplate: String {
        guard let measurement = current?.value else {
            return "\(GreekLetters.mathematicalItalicCapitalOmicron.rawValue):n/a"
        }
        return String(format: "\(GreekLetters.mathematicalBoldCapitalOmicron.rawValue):%.1f", measurement.value)
    }

    var maxValue: Measurement<UnitIncidence> {
        return measurements.map({ $0.value }).max() ?? Measurement<UnitIncidence>(value: 0.0, unit: .casesper100k)
    }

    var minValue: Measurement<UnitIncidence> {
        return Measurement<UnitIncidence>(value: 0.0, unit: .casesper100k)
    }

    var current: Incidence? {
        return measurements.last(where: { ($0.timestamp <= Date.now) && (($0.quality == .good) || ($0.quality == .uncertain)) })
    }

    var trend: String {
        var symbol = "questionmark.circle"
        if let currentIncidence = self.current {
            if let nextIncidence = measurements.last(where: { $0.timestamp < currentIncidence.timestamp }) {
                let currentValue = currentIncidence.value
                let previousValue = nextIncidence.value
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
            if let sensor = try await incidenceController.refreshIncidence(for: location) {
                self.sensor = sensor
                self.measurements = sensor.measurements.sorted(by: { $0.timestamp < $1.timestamp })
                if let current = Self.nowCast(data: self.measurements, alpha: 0.33) {
                    self.measurements.append(current)
                    if let forecast = await Self.forecast(data: self.measurements) {
                        self.measurements.append(contentsOf: forecast)
                    }
                }
                self.timestamp = sensor.timestamp
                MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
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

    private static func nowCast(
        data: Measurement<UnitIncidence>, previous: Measurement<UnitIncidence>, alpha: Double
    ) -> Measurement<UnitIncidence> {
        let value = alpha * data.value + (1 - alpha) * previous.value
        return Measurement<UnitIncidence>(value: value, unit: .casesper100k)
    }

    private static func forecast(data: [Incidence]?) async -> [Incidence]? {
        var forecast: [Incidence]? = nil
        guard let historicalData = data, historicalData.count > 0 else {
            return nil
        }
        let unit = historicalData[0].value.unit
        let historicalDataPoints = historicalData.map { incidence in
            TimeSeriesPoint(timestamp: incidence.timestamp, value: incidence.value.value)
        }
        let predictor = ARIMAPredictor(parameters: ARIMAParameters(p: 2, d: 1, q: 1), interval: .daily)
        do {
            try predictor.addData(historicalDataPoints)
            let prediction = try predictor.forecast(duration: 42 * 24 * 3600) // 42 days
            forecast = prediction.forecasts.map { forecast in
                Incidence(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
            }
        }
        catch {
            print("Forecasting error: \(error)")
        }
        return forecast
    }
}
