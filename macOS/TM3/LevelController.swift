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
    func refreshLevel(for location: Location) async throws -> LevelSensor? {
        if let nearestStation = try await fetchNearestStation(location: location) {
            if let measurements = try await fetchMeasurements(station: nearestStation) {
                if let placemark = await LocationController.reverseGeocodeLocation(location: nearestStation.location) {
                    return LevelSensor(
                        id: nearestStation.name, placemark: placemark, location: nearestStation.location, measurements: measurements, timestamp: Date.now)
                }
            }
        }
        return nil
    }

    private func fetchNearestStation(location: Location) async throws -> LevelStation? {
        var nearestStation: LevelStation? = nil
        if let data = try await WSVAPI.fetchStations() {
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
        if let data = try await OSMAPI.fetchWaterways(for: location, radius: 50000) {
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
        if let data = try await WSVAPI.fetchMeasurements(for: station.id) {
            measurements = try Self.parseLevels(data: data)
        }
        return measurements
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

    private static func parseTimestamp(string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }

    private static func forecast(data: [Level]?, count: Int) -> [Level]? {
        guard let data = data, data.count > 0, count > 0 else {
            return nil
        }
        let historicalData = [Level](data.prefix(count))
        if let latest = historicalData.max(by: { $0.timestamp < $1.timestamp }) {
            return Self.initializeForecast(from: latest.timestamp, count: count)
        }
        return nil
    }

    private static func initializeForecast(from: Date, count: Int) -> [Level]? {
        guard count > 0 else {
            return nil
        }
        var forecast: [Level] = []
        for i in 1 ... count {
            if let timestamp = Calendar.current.date(byAdding: .minute, value: i * 15, to: from) {
                forecast.append(Level(value: Measurement<UnitLength>(value: 0, unit: .centimeters), quality: .unknown, timestamp: timestamp))
            }
        }
        return forecast
    }
}
