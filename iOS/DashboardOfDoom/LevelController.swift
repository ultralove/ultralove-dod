import Foundation

typealias Level = ProcessValue<UnitLength>

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
    func refreshLevel(for location: Location) async throws -> LevelSensor? {
        if let nearestStation = try await fetchNearestStation(location: location) {
            var measurements: [Level] = []
            if let level = try await fetchMeasurements(station: nearestStation) {
                measurements.append(contentsOf: self.interpolateMeasurements(measurements: level))
                if let forecast = await Self.forecast(data: measurements) {
                    measurements.append(contentsOf: forecast)
                }
                if let placemark = await LocationManager.reverseGeocodeLocation(location: nearestStation.location) {
                    return LevelSensor(
                        id: nearestStation.name, placemark: placemark, location: nearestStation.location, measurements: measurements, timestamp: Date.now)
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
                        if let synchronizedStations = Self.synchronize(stations, with: nearestWaterway) {
                            if let synchronizedStation = Self.nearestStation(stations: synchronizedStations, location: location) {
                                nearestStation = LevelStation(id: synchronizedStation.id, name: nearestWaterway.name, location: synchronizedStation.location)
                            }
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
        if let data = try await LevelService.fetchWaterways(for: location, radius: 50000) {
            waterways = try Self.parseWaterways(data: data)
        }
        return waterways
    }

    static private func synchronize(_ stations: [LevelStation], with waterway: Waterway) -> [LevelStation]? {
        var synchronizedStations: [LevelStation]? = nil
        var foundStations: [LevelStation] = []
        for station in stations where station.name.lowercased().contains(waterway.name.lowercased()) {
            foundStations.append(station)
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

    private func fetchMeasurements(station: LevelStation) async throws -> [Level]? {
        var measurements: [Level]? = nil
        if let data = try await LevelService.fetchMeasurements(for: station.id) {
            measurements = try Self.parseLevels(data: data)
        }
        return measurements
    }

    private static func parseTimestamp(string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }

    private static func parseLevels(data: Data) throws -> [Level]? {
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [[String: Any]] {
            var levels: [Level] = []
            for item in json {
                if let value = item["value"] as? Double {
                    if let timestamp = item["timestamp"] as? String {
                        if let date = Self.parseTimestamp(string: timestamp) {
                            let level = Measurement<UnitLength>(value: value, unit: .centimeters)
                            levels.append(Level(value: level.converted(to: .meters), quality: .good, timestamp: date))
                        }
                    }
                }
            }
            return levels
        }
        return nil
    }

    private func interpolateMeasurements(measurements: [Level]) -> [Level] {
        var interpolatedMeasurement: [Level] = []
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
                                Level(
                                    value: Measurement(value: last.value.value, unit: last.value.unit), quality: .uncertain,
                                    timestamp: current))
                    }
                    current = current.addingTimeInterval(60 * 15) // 15 minutes
                }
            }
        }
        return interpolatedMeasurement
    }

    private static func forecast(data: [Level]?) async -> [Level]? {
        var forecast: [Level]? = nil
        guard let historicalData = data, historicalData.count > 0 else {
            return nil
        }
        let unit = historicalData[0].value.unit
        let historicalDataPoints = historicalData.map { incidence in
            TimeSeriesPoint(timestamp: incidence.timestamp, value: incidence.value.value)
        }
        let predictor = ARIMAPredictor(parameters: ARIMAParameters(p: 2, d: 1, q: 1), interval: .quarterHourly)
        do {
            try predictor.addData(historicalDataPoints)
            let prediction = try predictor.forecast(duration: 36 * 3600)  // 1.5 days
            forecast = prediction.forecasts.map { forecast in
                Level(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
        }
            }
        catch {
            print("Forecasting error: \(error)")
        }
        return forecast
    }
}
