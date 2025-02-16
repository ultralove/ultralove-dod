import SwiftUI

@Observable class RadiationViewModel: LocationViewModel {
    private let radiationController = RadiationController()

    var sensor: RadiationSensor?
    var measurements: [Radiation] = []
    var timestamp: Date? = nil

    var faceplate: String {
        guard let measurement = current?.value else {
            return "\(GreekLetters.mathematicalItalicCapitalGamma.rawValue):n/a"
        }
        return String(format: "\(GreekLetters.mathematicalBoldCapitalGamma.rawValue):%.3f", measurement.value)
    }

    var maxValue: Measurement<UnitRadiation> {
        return measurements.map({ $0.value }).max() ?? Measurement<UnitRadiation>(value: 0.0, unit: .microsieverts)
    }

    var minValue: Measurement<UnitRadiation> {
        return Measurement<UnitRadiation>(value: 0.0, unit: .microsieverts)
    }

    var current: Radiation? {
        return measurements.last(where: { ($0.timestamp <= Date.now) && ($0.quality == .good) } )
    }

    var trend: String {
        var symbol = "questionmark.circle"
        if let currentRadiation =  self.current {
            if let previousRadiation = measurements.last(where: { $0.timestamp < currentRadiation.timestamp }) {
                let currentValue = currentRadiation.value
                let previousValue = previousRadiation.value
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
            if let sensor = try await radiationController.refreshRadiation(for: location) {
                self.sensor = sensor
                self.measurements = sensor.measurements.sorted(by: { $0.timestamp < $1.timestamp })
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

    private static func forecast(data: [Radiation]?) async -> [Radiation]? {
        var forecast: [Radiation]? = nil
        guard let historicalData = data, historicalData.count > 0 else {
            return nil
        }
        let unit = historicalData[0].value.unit
        let historicalDataPoints = historicalData.map { incidence in
            TimeSeriesPoint(timestamp: incidence.timestamp, value: incidence.value.value)
    }
        let predictor = ARIMAPredictor(parameters: ARIMAParameters(p: 2, d: 1, q: 1), interval: .hourly)
        do {
            try predictor.addData(historicalDataPoints)
            let prediction = try predictor.forecast(duration: 72 * 3600) // 3 days
            forecast = prediction.forecasts.map { forecast in
                Radiation(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
        }
            }
        catch {
            print("Forecasting error: \(error)")
        }
        return forecast
    }
}
