import Foundation
import SwiftUI

@Observable class SurveyViewModel: Identifiable, SubscriberProtocol {
    private let surveyController = SurveyController()

    let id = UUID()
    var sensor: SurveySensor?
    var measurements: [SurveySelector: [Survey]] = [:]
    var timestamp: Date? = nil

    init() {
        let subscriptionManager = SubscriptionManager.shared
        subscriptionManager.addSubscription(id: id, delegate: self, timeout: 30)  // 30 minutes
    }

    var maxValue: Measurement<Dimension> {
        return Measurement(value: 66.67, unit: UnitPercentage.percent)
    }

    var minValue: Measurement<Dimension> {
        return Measurement(value: 0.0, unit: UnitPercentage.percent)
    }

    func current(selector: SurveySelector) -> Survey? {
        var current: Survey? = nil
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

    func trend(selector: SurveySelector) -> String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToLastUTCDayChange(from: Date.now) {
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
                print("\(Date.now): Survey: Refreshing data...")
                await self.synchronizeData(sensor: sensor, measurements: measurements)
                print("\(Date.now): Survey: Done.")
            }
        }
        catch {
            trace.error("Error refreshing data: %@", error.localizedDescription)
        }
    }

    @MainActor func synchronizeData(sensor: SurveySensor, measurements: [SurveySelector: [Survey]]) async -> Void {
        self.sensor = sensor
        self.measurements = measurements
        self.timestamp = sensor.timestamp
//        This messes up the map display if it adds the location of the Bundestag election polls
//        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }


    private func interpolateMeasurements(measurements: [SurveySelector: [Survey]]) async -> [SurveySelector: [Survey]] {
        var interpolatedMeasurements: [SurveySelector: [Survey]] = [:]
        for(selector, measurement) in measurements {
            interpolatedMeasurements[selector] = await self.interpolateMeasurement(measurements: measurement)
        }
        return interpolatedMeasurements
    }

    private func interpolateMeasurement(measurements: [Survey]) async -> [Survey] {
        var interpolatedMeasurement: [Survey] = []
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
                                Survey(
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

    private func aggregateMeasurements(measurements: [SurveySelector: [Survey]]) async -> [SurveySelector: [Survey]] {
        var aggregatedMeasurements: [SurveySelector: [Survey]] = [:]
        for (selector, measurement) in measurements {
            let uniqueMeasurements = Dictionary(grouping: measurement) { $0.timestamp }
                .map { timestamp, values in
                    self.aggregateMeasurement(timestamp: timestamp, measurements: values, quality: .uncertain)
                }.sorted(by: { $0.timestamp < $1.timestamp })
            aggregatedMeasurements[selector] = uniqueMeasurements
        }
        return aggregatedMeasurements
    }

    private func aggregateMeasurement(timestamp: Date, measurements: [Survey], quality: ProcessValueQuality) -> Survey {
        let value = measurements.map(\.value.value).reduce(0, +) / Double(measurements.count)
        return Survey(value: Measurement<UnitPercentage>(value: value, unit: .percent), quality: quality, timestamp: timestamp)
    }

    private static func forecast(data: [Survey]?) -> [Survey]? {
        var forecast: [Survey]? = nil
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
                Survey(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
    }
        }
        catch {
            print("Forecasting error: \(error)")
        }
        return forecast
    }
}
