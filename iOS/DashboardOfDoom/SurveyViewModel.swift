import Foundation
import SwiftUI

@Observable class SurveyViewModel: LocationViewModel {
    private let surveyController = SurveyController()

    var sensor: SurveySensor?
    var measurements: [SurveySelector: [Survey]] = [:]
    var current: [SurveySelector: Survey] = [:]
    var timestamp: Date? = nil

    var maxValue: Measurement<Dimension> {
        return Measurement(value: 66.67, unit: UnitPercentage.percent)
    }

    var minValue: Measurement<Dimension> {
        return Measurement(value: 0.0, unit: UnitPercentage.percent)
    }

    func faceplate(selector: SurveySelector) -> String {
        guard let measurement = current[selector]?.value else {
            return "\(GreekLetters.mathematicalItalicCapitalNu.rawValue):n/a"
        }
        return String(format: "\(GreekLetters.mathematicalBoldCapitalNu.rawValue):%.0f%@", measurement.value, measurement.unit.symbol)
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

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await surveyController.refreshGlobalSurveys(for: location) {
                self.sensor = sensor
                let measurements = sensor.measurements
                self.measurements = await self.interpolateMeasurements(measurements: await self.aggregateMeasurements(measurements: measurements))
                self.current = await self.aggregateCurrent(measurements: measurements)
                self.timestamp = sensor.timestamp
//                This messes up the map display if it adds the location of the Bundestag election poll
//                self.updateRegion(for: self.id, with: sensor.location)
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")
        }
    }

    private func interpolateMeasurements(measurements: [SurveySelector: [Survey]]) async -> [SurveySelector: [Survey]] {
        var interpolatedMeasurements: [SurveySelector: [Survey]] = [:]
        for(selector, measurement) in measurements {
            interpolatedMeasurements[selector] = self.interpolateMeasurement(measurements: measurement)
        }
        return interpolatedMeasurements
    }

    private func interpolateMeasurement(measurements: [Survey]) -> [Survey] {
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
                            .append(Survey(value: Measurement(value: last.value.value, unit: UnitPercentage.percent), quality: .uncertain, timestamp: current))
                    }
                    current = current.addingTimeInterval(60 * 60 * 24)
                }
            }
        }
        return interpolatedMeasurement
    }

    private func aggregateMeasurements(measurements: [SurveySelector: [Survey]]) async -> [SurveySelector: [Survey]] {
        var aggregatedMeasurements: [SurveySelector: [Survey]] = [:]
        for (selector, measurement) in measurements {
            var uniqueMeasurements = Dictionary(grouping: measurement) { $0.timestamp }
                .map { timestamp, values in
                    self.aggregateMeasurement(timestamp: timestamp, measurements: values, quality: .uncertain)
                }.sorted(by: { $0.timestamp < $1.timestamp })
            if let forecast = await Self.forecast(data: uniqueMeasurements) {
                uniqueMeasurements.append(contentsOf: forecast)
            }
            aggregatedMeasurements[selector] = uniqueMeasurements
        }
        return aggregatedMeasurements
    }

    private func aggregateMeasurement(timestamp: Date, measurements: [Survey], quality: QualityCode) -> Survey {
        let value = measurements.map(\.value.value).reduce(0, +) / Double(measurements.count)
        return Survey(value: Measurement<UnitPercentage>(value: value, unit: .percent), quality: quality, timestamp: timestamp)
    }

    private func aggregateCurrent(measurements: [SurveySelector: [Survey]]) async -> [SurveySelector: Survey] {
        var aggregated: [SurveySelector: Survey] = [:]
        for (selector, measurement) in measurements {
            aggregated[selector] = measurement.max(by: { $0.timestamp < $1.timestamp })
        }
        return aggregated
    }

    private static func forecast(data: [Survey]?) async -> [Survey]? {
        guard let data = data, data.count > 0 else { return nil }
        if let latest = data.max(by: { $0.timestamp < $1.timestamp }) {
            return await Self.initializeForecast(from: latest.timestamp, count: Int(Double(data.count) * 0.33))
        }
        return nil
    }

    private static func initializeForecast(from: Date, count: Int) async -> [Survey]? {
        guard count > 0 else {
            return nil
        }
        var forecast: [Survey] = []
        for i in 1 ... count {
            let timestamp = from.addingTimeInterval(TimeInterval(i * 60 * 60 * 24))
            forecast.append(Survey(value: Measurement(value: 0, unit: UnitPercentage.percent), quality: .unknown, timestamp: timestamp))
        }
        return forecast
    }
}
