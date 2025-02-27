import Foundation

typealias Particle = ProcessValue<UnitConcentrationMass>

struct ParticleStation {
    let id: String
    let code: String
    let name: String
    let location: Location
}

enum ParticleStationType: Int {
    case background = 1
    case industry = 2
    case traffic = 3
}

enum ParticleStationSettings: Int {
    case urban = 1
    case suburban = 2
    case rural = 3
    case ruralSecluded = 4
    case ruralRegional = 5
    case ruralNearTown = 6
}

struct ParticleComponent {
}

class ParticleController {
    func refreshParticles(for location: Location) async throws -> ParticleSensor? {
        if let nearestStation = try await Self.fetchNearestStation(location: location) {
            if let placemark = await LocationManager.reverseGeocodeLocation(location: nearestStation.location) {
                if let interval = Self.calculateTimeInterval(span: 21 * 24 * 60 * 60) {  // 21 days
                    if var measurements = try await Self.fetchMeasurements(station: nearestStation, from: interval.from, to: interval.to) {
                        if let forecastInterval = Self.calculateForecastTimeInterval(span: 14 * 24 * 60 * 60) {  // 7 days
                            if let forecast = try await Self.fetchForecasts(
                                station: nearestStation, from: forecastInterval.from, to: forecastInterval.to)
                            {
                                for (selector, values) in measurements {
                                    var actual = values
                                    actual.append(contentsOf: forecast[selector] ?? [])
                                    measurements[selector] = actual
                                }
                            }
                            return ParticleSensor(
                                id: nearestStation.name, placemark: placemark, location: nearestStation.location, measurements: measurements,
                                timestamp: Date.now)
                        }
                    }
                }
            }
        }
        return nil
    }

    private static func calculateTimeInterval(span: TimeInterval) -> (from: Date, to: Date)? {
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
        if let next = Date.roundToNextHour(from: Date.now) {
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

    private static func fetchNearestStation(location: Location) async throws -> ParticleStation? {
        var nearestStation: ParticleStation? = nil
        if let data = try await ParticleService.fetchStations() {
            let stations = try await Self.parseStations(from: data)
            if stations.count > 0 {
                nearestStation = Self.nearestStation(stations: stations, location: location)
            }
        }
        return nearestStation
    }

    private static func parseStations(from data: Data) async throws -> [ParticleStation] {
        var stations: [ParticleStation] = []
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let features = json["data"] as? [String: [Any]] {
                for (id, elements) in features {
                    if let code = elements[1] as? String, let name = elements[2] as? String {
                        if let longitudeString = elements[7] as? String, let latitudeString = elements[8] as? String {
                            if let longitude = Double(longitudeString), let latitude = Double(latitudeString) {
                                stations.append(
                                    ParticleStation(
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

    private static func nearestStation(stations: [ParticleStation], location: Location) -> ParticleStation? {
        var nearestStation: ParticleStation? = nil
        var minDistance = Measurement(value: 1000.0, unit: UnitLength.kilometers)  // This is more than the distance from List to Oberstdorf (960km)
        for station in stations {
            let distance = haversineDistance(location_0: station.location, location_1: location)
            if distance < minDistance {
                minDistance = distance
                nearestStation = station
            }
        }
        return nearestStation
    }

    private static func fetchMeasurements(station: ParticleStation, from: Date, to: Date) async throws -> [ParticleSelector: [Particle]]? {
        var measurements: [ParticleSelector: [Particle]]? = nil
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
                                                    if let selector = ParticleSelector(rawValue: componentId) {
                                                        if let unit = Self.selectMeasurementUnit(component: selector) {
                                                            if let value = measurementItem[1] as? Double {
                                                                let measurement = Particle(
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
        if measurements != nil {
            for (selector, values) in measurements! {
                measurements?[selector] = values.sorted(by: { $0.timestamp < $1.timestamp })
            }
        }
        return measurements
    }

    private static func fetchForecasts(station: ParticleStation, from: Date, to: Date) async throws -> [ParticleSelector: [Particle]]? {
        var measurements: [ParticleSelector: [Particle]]? = nil
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
                                                    if let selector = ParticleSelector(rawValue: componentId) {
                                                        if let unit = Self.selectMeasurementUnit(component: selector) {
                                                            if let value = measurementItem[1] as? Double {
                                                                let measurement = Particle(
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

    static private func selectMeasurementUnit(component: ParticleSelector) -> UnitConcentrationMass? {
        switch component {
            case .pm10:
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .co:
                return UnitConcentrationMass.milligramsPerCubicMeter
            case .o3:
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .so2:
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .no2:
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .lead:
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .benzoapyrene:
                return UnitConcentrationMass.nanogramsPerCubicMeter
            case .benzene:
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .pm25:
                return UnitConcentrationMass.microgramsPerCubicMeter
            case .arsenic:
                return UnitConcentrationMass.nanogramsPerCubicMeter
            case .cadmium:
                return UnitConcentrationMass.nanogramsPerCubicMeter
            case .nickel:
                return UnitConcentrationMass.nanogramsPerCubicMeter
        }
    }

}
