import Foundation

struct LevelStation {
    let id: String
    let name: String
    let location: Location
}

struct Waterway {
    let name: String
    let location: Location
}

class LevelController {
    private let measurementDistance: TimeInterval
    private let forecastDuration: TimeInterval

    init() {
        self.measurementDistance = 900  // 15 minutes
        self.forecastDuration = 36 * 4 * self.measurementDistance  // 3 days
    }

    func refreshLevel(for location: Location) async throws -> LevelSensor? {
        if let nearestStation = try await fetchNearestStation(location: location) {
            trace.debug("Nearest station: \(nearestStation)")
            if let level = try await fetchMeasurements(station: nearestStation) {
                var measurements: [ProcessValue<Dimension>] = []
                measurements.append(contentsOf: Self.interpolateMeasurements(measurements: level, distance: self.measurementDistance))
                measurements.append(contentsOf: Self.forecastMeasurements(data: measurements, duration: self.forecastDuration))
                if let placemark = await LocationManager.reverseGeocodeLocation(location: nearestStation.location) {
                    return LevelSensor(
                        id: nearestStation.name, placemark: placemark, customData: ["icon": "water.waves"], location: nearestStation.location,
                        measurements: measurements,
                        timestamp: Date.now)
                }
            }
        }
        return nil
    }

    private func fetchNearestStation(location: Location) async throws -> LevelStation? {
        var nearestStation: LevelStation? = nil
        if let data = try await LevelService.fetchStations() {
            if let stations = try Self.parseStations(from: data) {
                if let waterways = try await fetchNearestWaterways(for: location) {
                    if let nearestWaterway = Self.nearestWaterway(waterways: waterways, location: location) {
                        trace.debug("Nearest waterway: \(nearestWaterway)")
                        if let synchronizedStations = Self.synchronize(stations, with: nearestWaterway) {
                            if let synchronizedStation = Self.nearestStation(stations: synchronizedStations, location: location) {
                                nearestStation = LevelStation(
                                    id: synchronizedStation.id, name: nearestWaterway.name, location: synchronizedStation.location)
                            }
                        }
                        else {
                            trace.warning("No synchronized stations found, falling back to nearest station")
                            if let station = Self.nearestStation(stations: stations, location: location) {
                                nearestStation = LevelStation(
                                    id: station.id, name: self.capitalizeGerman(text: station.name), location: station.location)
                            }
                        }
                        if let nearestStation = nearestStation {
                            trace.debug("Nearest station: \(nearestStation)")
                        }
                        else {
                            trace.error("No station found")
                        }
                    }
                }
            }
        }
        return nearestStation
    }

    private static func parseStations(from data: Data) throws -> [LevelStation]? {
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [[String: Any]] {
            var stations: [LevelStation] = []
            for item in json {
                if let id = item["uuid"] as? String {
                    if let latitude = item["latitude"] as? Double {
                        if let longitude = item["longitude"] as? Double {
                            if let water = item["water"] as? [String: Any] {
                                if let name = water["longname"] as? String {
                                    let location = Location(latitude: latitude, longitude: longitude)
                                    stations.append(LevelStation(id: id, name: name, location: location))
                                }
                            }
                        }
                    }
                }
            }
            return stations
        }
        return nil
    }

    private static func nearestStation(stations: [LevelStation], location: Location) -> LevelStation? {
        var nearestStation: LevelStation? = nil
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

    private func fetchNearestWaterways(for location: Location) async throws -> [Waterway]? {
        var waterways: [Waterway]? = nil
        if let data = try await LevelService.fetchWaterways(for: location, radius: 10000) {
            waterways = try Self.parseWaterways(data: data)
        }
        return waterways
    }

    static private func synchronize(_ stations: [LevelStation], with waterway: Waterway) -> [LevelStation]? {
        var synchronizedStations: [LevelStation]? = nil
        var foundStations: [LevelStation] = []
        for station in stations where station.name.lowercased().contains(waterway.name.lowercased()) {
            let maxDistance = Measurement(value: 16.67, unit: UnitLength.kilometers)
            if haversineDistance(location_0: station.location, location_1: waterway.location) < maxDistance {
                foundStations.append(station)
            }
        }
        if foundStations.count > 0 {
            synchronizedStations = foundStations
        }
        return synchronizedStations
    }

    static private func parseWaterways(data: Data) throws -> [Waterway]? {
        var waterways: [Waterway]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["elements"] as? [[String: Any]] {
                var foundWaterways: [Waterway] = []
                for element in elements {
                    if let center = element["center"] as? [String: Any] {
                        if let latitude = center["lat"] as? Double, let longitude = center["lon"] as? Double {
                            if let tags = element["tags"] as? [String: Any] {
                                if let name = tags["name"] as? String {
                                    foundWaterways.append(Waterway(name: name, location: Location(latitude: latitude, longitude: longitude)))
                                }
                            }
                        }
                    }
                }
                if foundWaterways.count > 0 {
                    waterways = foundWaterways
                }
            }
        }
        return waterways
    }

    private static func nearestWaterway(waterways: [Waterway], location: Location) -> Waterway? {
        var nearestWaterway: Waterway? = nil
        var minDistance = Measurement(value: 1000.0, unit: UnitLength.kilometers)  // This is more than the distance from List to Oberstdorf (960km)
        for waterway in waterways {
            let distance = haversineDistance(location_0: waterway.location, location_1: location)
            if distance < minDistance {
                minDistance = distance
                nearestWaterway = waterway
            }
        }
        return nearestWaterway
    }

    private func fetchMeasurements(station: LevelStation) async throws -> [ProcessValue<Dimension>]? {
        var measurements: [ProcessValue<Dimension>]? = nil
        if let data = try await LevelService.fetchMeasurements(for: station.id) {
            measurements = try Self.parseLevels(data: data)
        }
        return measurements
    }

    private static func parseTimestamp(string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }

    private static func parseLevels(data: Data) throws -> [ProcessValue<Dimension>]? {
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [[String: Any]] {
            var levels: [ProcessValue<Dimension>] = []
            for item in json {
                if let value = item["value"] as? Double {
                    if let timestamp = item["timestamp"] as? String {
                        if let date = Self.parseTimestamp(string: timestamp) {
                            let level = Measurement<Dimension>(value: value, unit: UnitLength.centimeters)
                            levels.append(ProcessValue<Dimension>(value: level.converted(to: UnitLength.meters), quality: .good, timestamp: date))
                        }
                    }
                }
            }
            return levels
        }
        return nil
    }

    private static func interpolateMeasurements(measurements: [ProcessValue<Dimension>], distance: TimeInterval) -> [ProcessValue<Dimension>] {
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
                                    value: Measurement(value: last.value.value, unit: last.value.unit), quality: .uncertain,
                                    timestamp: current))
                    }
                    current = current.addingTimeInterval(distance)
                }
            }
        }
        return interpolatedMeasurement
    }

    private static func forecastMeasurements(data: [ProcessValue<Dimension>], duration: TimeInterval) -> [ProcessValue<Dimension>] {
        var forecastMeasurements: [ProcessValue<Dimension>] = []
        if data.count > 0 {
            let unit = data[0].value.unit
            let dataPoints = data.map { incidence in
                TimeSeriesPoint(timestamp: incidence.timestamp, value: incidence.value.value)
            }
            let predictor = ARIMAPredictor(parameters: ARIMAParameters(p: 2, d: 1, q: 1), interval: .quarterHourly)
            do {
                try predictor.addData(dataPoints)
                let prediction = try predictor.forecast(duration: duration)
                forecastMeasurements = prediction.forecasts.map { forecast in
                    ProcessValue<Dimension>(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
                }
            }
            catch {
                print("Forecasting error: \(error)")
            }
        }
        return forecastMeasurements
    }

    private func capitalizeGerman(text: String) -> String {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        let properCasedWords = words.map { word -> String in
            guard !word.isEmpty else { return word }

            let firstChar = String(word.prefix(1)).uppercased()
            let restOfWord = String(word.dropFirst()).lowercased()

            return firstChar + restOfWord
        }
        return properCasedWords.joined(separator: " ")
    }
}
