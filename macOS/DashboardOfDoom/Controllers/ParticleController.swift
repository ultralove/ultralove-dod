import Foundation

class ParticleController: ProcessController {
    private let measurementDuration: TimeInterval
    private let forecastDuration: TimeInterval
    #if os(iOS)
    private static let smoothingFactor = 13
    #else
    private static let smoothingFactor = 4
    #endif

    init() {
        self.measurementDuration = 21 * 24 * 60 * 60  // 21 days
        self.forecastDuration = 7 * 24 * 60 * 60  // 7 days
    }

    func refreshData(for location: Location) async throws -> ProcessSensor? {
        do {
            if let interval = Self.calculateMeasurementTimeInterval(span: self.measurementDuration) {
                if let nearestStation = await Self.fetchNearestStation(location: location, from: interval.from, to: interval.to) {
                    if let placemark = await LocationManager.reverseGeocodeLocation(location: nearestStation.location) {
                        if var measurements = try await Self.fetchMeasurements(station: nearestStation, from: interval.from, to: interval.to) {
                            if let forecastInterval = Self.calculateForecastTimeInterval(span: self.forecastDuration) {
                                if let forecast = try await Self.fetchForecasts(
                                    station: nearestStation, from: forecastInterval.from, to: forecastInterval.to)
                                {
                                    for (selector, values) in measurements {
                                        var actual = self.interpolateMeasurement(measurements: values)
                                        actual.append(contentsOf: forecast[selector] ?? [])
                                        measurements[selector] = movingAverage(data: actual, windowSize: Self.smoothingFactor)
                                    }
                                }
                                return ProcessSensor(
                                    name: nearestStation.name, location: nearestStation.location, placemark: placemark,
                                    customData: ["icon": "aqi.medium"],
                                    measurements: measurements,
                                    timestamp: Date.now)
                            }
                        }
                    }
                }
            }
        }
        catch {
            trace.error("Error refreshing particulate matter: %@", error.localizedDescription)
        }
        return nil
    }

    private func interpolateMeasurement(measurements: [ProcessValue<Dimension>]) -> [ProcessValue<Dimension>] {
        var interpolatedMeasurement: [ProcessValue<Dimension>] = []
        if let start = measurements.first?.timestamp, let end = measurements.last?.timestamp {
            let unit = measurements[0].value.unit
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
                                    value: Measurement(value: last.value.value, unit: unit), quality: .uncertain,
                                    timestamp: current))
                    }
                    current = current.addingTimeInterval(60 * 60)
                }
            }
        }
        return gaussianSmoothing(data: interpolatedMeasurement, windowSize: 11, sigma: 2.3)
    }

    private static func calculateMeasurementTimeInterval(span: TimeInterval) -> (from: Date, to: Date)? {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: Date.now)
        var adjustedComponents = components
        adjustedComponents.minute = 0  // Reset minutes to 0
        adjustedComponents.second = 0  // Reset seconds to 0
        if let to = Calendar.current.date(from: adjustedComponents) {
            let from = to.addingTimeInterval(-1 * span)  // rewind
            return (from, to)
        }
        return nil
    }

    private static func calculateForecastTimeInterval(span: TimeInterval) -> (from: Date, to: Date)? {
        if let next = Date.round(from: Date.now, strategy: .previousQuarterHour) {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: next)
            var adjustedComponents = components
            adjustedComponents.minute = 0  // Reset minutes to 0
            adjustedComponents.second = 0  // Reset seconds to 0
            if let from = Calendar.current.date(from: adjustedComponents) {
                let to = from.addingTimeInterval(span)  // forward
                return (from, to)
            }
        }
        return nil
    }

    struct Station {
        let id: String
        let code: String
        let name: String
        let location: Location
    }

    private static func fetchNearestStation(location: Location, from: Date, to: Date) async -> Station? {
        var nearestStation: Station? = nil
        do {
            if let data = try await ParticleService.fetchStations(from: from, to: to) {
                let unsortedStations = try await Self.parseStations(from: data)
                if unsortedStations.count > 0 {
                    let sortedStations = unsortedStations.sorted {
                        haversineDistance(location_0: location, location_1: $0.location)
                            < haversineDistance(location_0: location, location_1: $1.location)
                    }

                    if UserDefaults.standard.bool(forKey: "nearestParticleSensor") == true {
                        nearestStation = sortedStations.first
                    }
                    else {
                    if let selectedStation = await Self.selectStation(stations: sortedStations) {
                        nearestStation = selectedStation
                    }
                    else {
                        nearestStation = sortedStations.first
                    }
                }
            }
        }
        }
        catch {
            trace.error("Error fetching stations: %@", error.localizedDescription)
        }
        return nearestStation
    }

    private static func parseStations(from data: Data) async throws -> [Station] {
        var stations: [Station] = []
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let features = json["data"] as? [String: [Any]] {
                for (id, elements) in features {
                    if let code = elements[1] as? String, let name = elements[2] as? String {
                        if let longitudeString = elements[7] as? String, let latitudeString = elements[8] as? String {
                            if let longitude = Double(longitudeString), let latitude = Double(latitudeString) {
                                stations.append(
                                    Station(
                                        id: id, code: code, name: name,
                                        location: Location(latitude: Double(latitude), longitude: Double(longitude))))
                            }
                        }
                    }
                }
            }
        }
        return stations
    }

    private static func selectStation(stations: [Station]) async -> Station? {
        var selectedStation: Station? = nil
        let to = Date.now.addingTimeInterval(-1 * 24 * 60 * 60)
        let from = to.addingTimeInterval(-1 * 24 * 60 * 60)
        for station in stations {
            if let measurements = try? await fetchMeasurements(station: station, from: from, to: to) {
                if stationHasRelevantMeasurements(measurements) == true {
                    selectedStation = station
                    break
                }
            }
        }
        return selectedStation
    }

    private static func stationHasRelevantMeasurements(_ measurements: [ProcessSelector: [ProcessValue<Dimension>]]) -> Bool {
        let relevantSelectors: Set<ProcessSelector> = [
            .particle(.pm10), .particle(.pm25), .particle(.no2), .particle(.o3)
        ]
        return relevantSelectors.isSubset(of: Set(measurements.keys))
    }

    private static func fetchMeasurements(station: Station, from: Date, to: Date) async throws -> [ProcessSelector: [ProcessValue<Dimension>]]? {
        var measurements: [ProcessSelector: [ProcessValue<Dimension>]]? = nil
        do {
            if let data = try await ParticleService.fetchMeasurements(code: station.code, from: from, to: to) {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
                    if let features = json["data"] as? [String: Any] {
                        if let featureId = features.keys.first {
                            if let measurementSequence = features[featureId] as? [String: [Any]] {
                                for (_, measurementValues) in measurementSequence {
                                    if let measurementEnd = measurementValues[0] as? String {
                                        if let timestamp = Date.fromString(measurementEnd, format: "yyyy-MM-dd HH:mm:ss") {
                                            for measurementItems in measurementValues[3...] {
                                                if let measurementItem = measurementItems as? [Any] {
                                                    if let componentId = measurementItem[0] as? Int {
                                                        if let selector = ProcessSelector.particle(from: componentId) {
                                                            if let unit = Self.selectMeasurementUnit(component: selector) {
                                                                if let value = measurementItem[1] as? Double {
                                                                    let measurement = ProcessValue<Dimension>(
                                                                        value: Measurement(value: value, unit: unit), quality: .good,
                                                                        timestamp: timestamp)
                                                                    if measurements == nil {
                                                                        measurements = [selector: [measurement]]
                                                                    }
                                                                    else if measurements?[selector] == nil {
                                                                        measurements?[selector] = [measurement]
                                                                    }
                                                                    else {
                                                                        measurements?[selector]?.append(measurement)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch {
            trace.error("Error fetching measurements: %@", error.localizedDescription)
        }
        if measurements != nil {
            for (selector, values) in measurements! {
                measurements?[selector] = values.sorted(by: { $0.timestamp < $1.timestamp })
            }
        }
        return measurements
    }

    private static func fetchForecasts(station: Station, from: Date, to: Date) async throws -> [ProcessSelector: [ProcessValue<Dimension>]]? {
        var measurements: [ProcessSelector: [ProcessValue<Dimension>]]? = nil
        if let data = try await ParticleService.fetchForecasts(code: station.code, from: from, to: to) {
            if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
                if let features = json["data"] as? [String: Any] {
                    if let featureId = features.keys.first {
                        if let measurementSequence = features[featureId] as? [String: [Any]] {
                            for (_, measurementValues) in measurementSequence {
                                if let measurementEnd = measurementValues[0] as? String {
                                    if let timestamp = Date.fromString(measurementEnd, format: "yyyy-MM-dd HH:mm:ss") {
                                        for measurementItems in measurementValues[4...] {
                                            if let measurementItem = measurementItems as? [Any] {
                                                if let componentId = measurementItem[0] as? Int {
                                                    if let selector = ProcessSelector.particle(from: componentId) {
                                                        if let unit = Self.selectMeasurementUnit(component: selector) {
                                                            if let value = measurementItem[1] as? Double {
                                                                let measurement = ProcessValue<Dimension>(
                                                                    value: Measurement(value: value, unit: unit), quality: .uncertain,
                                                                    timestamp: timestamp)
                                                                if measurements == nil {
                                                                    measurements = [selector: [measurement]]
                                                                }
                                                                else if measurements?[selector] == nil {
                                                                    measurements?[selector] = [measurement]
                                                                }
                                                                else {
                                                                    measurements?[selector]?.append(measurement)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if measurements != nil {
            for (selector, values) in measurements! {
                measurements?[selector] = values.sorted(by: { $0.timestamp < $1.timestamp })
            }
        }
        return measurements
    }

    static private func selectMeasurementUnit(component: ProcessSelector) -> UnitConcentrationMass? {
        switch component {
            case .particle(.pm10):
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .particle(.co):
                return UnitConcentrationMass.milligramsPerCubicMeter
            case .particle(.o3):
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .particle(.so2):
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .particle(.no2):
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .particle(.lead):
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .particle(.benzoapyrene):
                return UnitConcentrationMass.nanogramsPerCubicMeter
            case .particle(.benzene):
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .particle(.pm25):
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .particle(.arsenic):
                return UnitConcentrationMass.nanogramsPerCubicMeter
            case .particle(.cadmium):
                return UnitConcentrationMass.nanogramsPerCubicMeter
            case .particle(.nickel):
                return UnitConcentrationMass.nanogramsPerCubicMeter
            default:
                return nil
        }
    }
}
