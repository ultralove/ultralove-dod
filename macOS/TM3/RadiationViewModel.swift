import SwiftUI

@Observable class RadiationViewModel: LocationViewModel {
    private let radiationController = RadiationController()

    var sensor: RadiationSensor?
    var measurements: [Radiation] = []
    var current: Radiation?
    var timestamp: Date? = nil

    var faceplate: String {
        if let measurement = current?.value {
            return String(format: "\(GreekLetters.mathematicalBoldCapitalGamma.rawValue):%.3f", measurement.value)
        }
        else {
            return "\(GreekLetters.mathematicalItalicCapitalGamma.rawValue):n/a"
        }
    }

    var maxValue: Measurement<UnitRadiation> {
        return measurements.map({ $0.value }).max() ?? Measurement<UnitRadiation>(value: 0.0, unit: .microsieverts)
    }

    var minValue: Measurement<UnitRadiation> {
        return Measurement<UnitRadiation>(value: 0.0, unit: .microsieverts)
    }

    var trend: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToLastDayChange(from: Date.now) {
            if let currentRadiation = measurements.first(where: { $0.timestamp == currentDate })?.value.value {
                if let nextDate = Date.roundToLastDayChange(from: Date.now.addingTimeInterval(60 * 60 * 24)) {
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
            if let sensor = try await radiationController.refreshRadiation(for: location) {
                self.sensor = sensor
                self.measurements = sensor.measurements
                if let current = self.measurements.max(by: { $0.timestamp < $1.timestamp }) {
                    self.current = current
                    if let forecast = await Self.forecast(data: self.measurements) {
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

    private static func forecast(data: [Radiation]?) async -> [Radiation]? {
        guard let data = data, data.count > 0 else { return nil }
        if let latest = data.max(by: { $0.timestamp < $1.timestamp }) {
            return await Self.initializeForecast(from: latest.timestamp, count: Int(Double(data.count) * 0.33))
        }
        return nil
    }

    private static func initializeForecast(from: Date, count: Int) async -> [Radiation]? {
        guard count > 0 else {
            return nil
        }
        var forecast: [Radiation] = []
        for i in 1 ... count {
            if let timestamp = Calendar.current.date(byAdding: .hour, value: i, to: from) {
                forecast.append(Radiation(value: Measurement<UnitRadiation>(value: 0, unit: .microsieverts), quality: .unknown, timestamp: timestamp))
            }
        }
        return forecast
    }
}
