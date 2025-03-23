import Foundation
import SwiftUI

@Observable class SurveyViewModel: Identifiable, ProcessSubscriberProtocol {
    private let surveyController = SurveyController()

    let id = UUID()
    var sensor: SurveySensor?
    var measurements: [SurveySelector: [ProcessValue<Dimension>]] = [:]
    var timestamp: Date? = nil

    init() {
        let processManager = ProcessManager.shared
        processManager.add(subscriber: self, timeout: 30)  // 30 minutes
    }

    var maxValue: Measurement<Dimension> {
        return Measurement(value: 66.67, unit: UnitPercentage.percent)
    }

    var minValue: Measurement<Dimension> {
        return Measurement(value: 0.0, unit: UnitPercentage.percent)
    }

    func current(selector: SurveySelector) -> ProcessValue<Dimension>? {
        var current: ProcessValue<Dimension>? = nil
        if let measurements = self.measurements[selector] {
            current = measurements.last(where: { $0.timestamp <= Date.now })
        }
        return current
    }

    func faceplate(selector: SurveySelector) -> String {
        guard let measurement = current(selector: selector)?.value else {
            return "\(MathematicalSymbols.mathematicalItalicCapitalNu.rawValue):n/a"
        }
        return String(format: "\(MathematicalSymbols.mathematicalBoldCapitalNu.rawValue):%.0f%@", measurement.value, measurement.unit.symbol)
    }

    var icon: String {
        if let customData = sensor?.customData {
            if let icon = customData["icon"] as? String {
                return icon
            }
        }
        return "questionmark.circle"
    }

    func trend(selector: SurveySelector) -> String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.round(from: Date.now, strategy: .lastUTCDayChange) {
            if let currentSurvey = measurements[selector]?.last(where: { $0.timestamp < currentDate }) {
                if let previousSurvey = measurements[selector]?.last(where: { $0.timestamp < currentSurvey.timestamp }) {
                    let currentValue = currentSurvey.value
                    let previousValue = previousSurvey.value
                    if currentValue > previousValue {
                        symbol = "arrow.up.forward.circle"
                    }
                    else if currentValue < previousValue {
                        symbol = "arrow.down.forward.circle"
                    }
                    else {
                        symbol = "arrow.right.circle"
                    }
                }
            }
        }
        return symbol
    }

    func gradient(selector: SurveySelector) -> LinearGradient {
        switch selector {
            case .fascists:
                return Gradient.fascists
            case .afd:
                return Gradient.fascists
            case .bsw:
                return Gradient.fascists
            case .clowns:
                return Gradient.clowns
            case .fdp:
                return Gradient.clowns
            case .cducsu:
                return Gradient.fascists
            case .spd:
                return Gradient.spd
            case .gruene:
                return Gradient.gruene
            case .linke:
                return Gradient.linke
            case .sonstige:
                return Gradient.sonstige
            default:
                return Gradient.linear
        }
    }

    func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await surveyController.refreshFederalSurveys(for: location) {
                let measurements = await self.interpolateMeasurements(measurements: await self.aggregateMeasurements(measurements: sensor.measurements))
                await self.synchronizeData(sensor: sensor, measurements: measurements)
            }
        }
        catch {
            trace.error("Error refreshing data: %@", error.localizedDescription)
        }
    }

    @MainActor func synchronizeData(sensor: SurveySensor, measurements: [SurveySelector: [ProcessValue<Dimension>]]) async -> Void {
        self.sensor = sensor
        self.measurements = measurements
        self.timestamp = sensor.timestamp
//        This messes up the map display if it adds the location of the Bundestag election polls
//        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }


    private func interpolateMeasurements(measurements: [SurveySelector: [ProcessValue<Dimension>]]) async -> [SurveySelector: [ProcessValue<Dimension>]] {
        var interpolatedMeasurements: [SurveySelector: [ProcessValue<Dimension>]] = [:]
        for (selector, measurement) in measurements {
            interpolatedMeasurements[selector] = await self.interpolateMeasurement(measurements: measurement)
        }
        return interpolatedMeasurements
    }

    private func interpolateMeasurement(measurements: [ProcessValue<Dimension>]) async -> [ProcessValue<Dimension>] {
        var interpolatedMeasurement: [ProcessValue<Dimension>] = []
        if let start = measurements.first?.timestamp, let end = measurements.last?.timestamp {
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
                                ProcessValue<Dimension>(
                                    value: Measurement(value: last.value.value, unit: UnitPercentage.percent), quality: .uncertain,
                                    timestamp: current))
                    }
                    current = current.addingTimeInterval(60 * 60 * 24)
                }
            }
        }
        if let forecast = Self.forecast(data: interpolatedMeasurement) {
            interpolatedMeasurement.append(contentsOf: forecast)
        }
        return interpolatedMeasurement
    }

    private func aggregateMeasurements(measurements: [SurveySelector: [ProcessValue<Dimension>]]) async -> [SurveySelector: [ProcessValue<Dimension>]] {
        var aggregatedMeasurements: [SurveySelector: [ProcessValue<Dimension>]] = [:]
        for (selector, measurement) in measurements {
            let uniqueMeasurements = Dictionary(grouping: measurement) { $0.timestamp }
                .map { timestamp, values in
                    self.aggregateMeasurement(timestamp: timestamp, measurements: values, quality: .uncertain)
                }.sorted(by: { $0.timestamp < $1.timestamp })
            aggregatedMeasurements[selector] = uniqueMeasurements
        }
        return aggregatedMeasurements
    }

    private func aggregateMeasurement(timestamp: Date, measurements: [ProcessValue<Dimension>], quality: ProcessQuality) -> ProcessValue<Dimension> {
        let value = measurements.map(\.value.value).reduce(0, +) / Double(measurements.count)
        let unit = measurements.count > 0 ? measurements[0].value.unit : UnitPercentage.percent // Use hardcoded unit if no measurements are available
        return ProcessValue<Dimension>(value: Measurement<Dimension>(value: value, unit: unit), quality: quality, timestamp: timestamp)
    }

    private static func forecast(data: [ProcessValue<Dimension>]?) -> [ProcessValue<Dimension>]? {
        var forecast: [ProcessValue<Dimension>]? = nil
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
            let prediction = try predictor.forecast(duration: 23 * 24 * 3600)  // 23 days
            forecast = prediction.forecasts.map { forecast in
                ProcessValue<Dimension>(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
            }
        }
        catch {
            print("Forecasting error: \(error)")
        }
        return forecast
    }
}
