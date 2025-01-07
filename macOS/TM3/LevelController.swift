import Foundation

struct Station {
    let id: String
    let name: String
    let water: String
    let km: Double
    let location: Location
}

class LevelController {

    func refreshLevel(for location: Location) async throws -> LevelSensor? {
        if let nearestStation = try await fetchNearestStation(location: location) {
            if let levels = try await fetchMeasurements(station: nearestStation) {
                return LevelSensor(station: nearestStation.name, level: levels, timestamp: Date.now)
            }
        }
        return nil
    }

    private func fetchNearestStation(location: Location) async throws -> Station? {
        let endpoint = "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations.json"
        guard let url = URL(string: endpoint) else { return nil }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        if let stations = try Self.parseStations(from: data) {
            if let nearestStation = Self.nearestStation(stations: stations, location: location) {
                print("Nearest station: \(nearestStation.name), \(nearestStation.water), \(nearestStation.km)km")
//                let associatedStations = stations.filter {
//                    let distance = haversineDistance(location_0: location, location_1: $0.location)
//                    return (distance) < Measurement(value: 10.0, unit: UnitLength.kilometers)
//                }
//                print("Found \(associatedStations.count) associated stations")
//                for associatedStation in associatedStations {
//                    print("Associated station: \(associatedStation.name), \(associatedStation.water), \(associatedStation.km)km")
//                }
                return nearestStation
            }
        }
        return nil
    }

    private static func parseStations(from data: Data) throws -> [Station]? {
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [[String: Any]] {
            var stations: [Station] = []
            for item in json {
                if let id = item["uuid"] as? String {
                    if let name = item["longname"] as? String {
                        if let km = item["km"] as? Double {
                            if let latitude = item["latitude"] as? Double {
                                if let longitude = item["longitude"] as? Double {
                                    if let water = item["water"] as? [String: Any] {
                                        if let river = water["longname"] as? String {
                                            stations.append(Station(id: id, name: name, water: river, km: km,
                                                                    location: Location(name: name, latitude: latitude, longitude: longitude)))
                                        }
                                    }
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

    private static func nearestStation(stations: [Station], location: Location) -> Station? {
        var nearestStation: Station? = nil
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

    private func fetchMeasurements(station: Station) async throws -> [Level]? {
        let endpoint = String(format: "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations/%@/W/measurements.json?start=P5D", station.id)
        guard let url = URL(string: endpoint) else { return nil }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return try Self.parseLevels(data: data)
    }

    private static func parseLevels(data: Data) throws -> [Level]? {
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [[String: Any]] {
            var levels: [Level] = []
            for item in json {
                if let value = item["value"] as? Double {
                    if let timestamp = item["timestamp"] as? String {
                        if let date = Self.parseTimestamp(string: timestamp) {
                            levels.append(Level(value: value / 100, date: date))
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
}
