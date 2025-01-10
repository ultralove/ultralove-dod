import Foundation

struct RadiationStation {
    let id: String
    let name: String
    let location: Location
}

class RadiationController {
    func refreshRadiation(for location: Location) async throws -> RadiationSensor? {
        if let nearestStation = try await Self.fetchNearestStation(location: location) {
            if let measurements = try await Self.fetchMeasurements(station: nearestStation) {
                return RadiationSensor(id: nearestStation.name, location: nearestStation.location, measurements: measurements, timestamp: Date.now)
            }
        }
        return nil
    }

    private static func fetchNearestStation(location: Location) async throws -> RadiationStation? {
        var nearestStation: RadiationStation? = nil
        let endpoint =
            "https://www.imis.bfs.de/ogc/opendata/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=opendata:odlinfo_odl_1h_latest&outputFormat=application/json"
        guard let url = URL(string: endpoint) else { return nil }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        let stations = try Self.parseStations(from: data)
        if stations.count > 0 {
            nearestStation = Self.nearestStation(stations: stations, location: location)
            if let nearestStation = nearestStation {
                print("Nearest station: \(nearestStation.name), \(nearestStation.id)")
            }
            else {
                print("Nearest station: none")
            }
        }
        return nearestStation
    }

    private static func parseStations(from data: Data) throws -> [RadiationStation] {
        var stations: [RadiationStation] = []
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let features = json["features"] as? [[String: Any]] {
                for feature in features {
                    if let geometry = feature["geometry"] as? [String: Any],
                        let coordinates = geometry["coordinates"] as? [Double]
                    {
                        let location = Location(name: "<Unused>", latitude: coordinates[1], longitude: coordinates[0])
                        if let properties = feature["properties"] as? [String: Any] {
                            if let id = properties["kenn"] as? String {
                                if let name = properties["name"] as? String {
                                    let siteStatus = properties["site_status"] as? Int
                                    if siteStatus == 1 {
                                        stations.append(RadiationStation(id: id, name: name, location: location))
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

    private static func nearestStation(stations: [RadiationStation], location: Location) -> RadiationStation? {
        var nearestStation: RadiationStation? = nil
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

    private static func fetchMeasurements(station: RadiationStation) async throws -> [Radiation]? {
        let endpoint = String(
            format:
                "https://www.imis.bfs.de/ogc/opendata/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=opendata:odlinfo_timeseries_odl_1h&outputFormat=application/json&viewparams=kenn:%@",
            station.id)
        guard let url = URL(string: endpoint) else { return nil }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return try Self.parseRadiation(data: data)
    }

    private static func parseRadiation(data: Data) throws -> [Radiation] {
        var measurements: [Radiation] = []
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let features = json["features"] as? [[String: Any]] {
                for feature in features {
                    if let properties = feature["properties"] as? [String: Any] {
                        if let dateString = properties["end_measure"] as? String {
                            let isoFormatter = ISO8601DateFormatter()
                            if let timestamp = isoFormatter.date(from: dateString) {
                                if let value = properties["value"] as? Double {
                                    let measurement = Radiation(
                                        value: Measurement(value: value, unit: UnitRadiation.microsieverts), quality: .good, timestamp: timestamp)
                                    measurements.append(measurement)
                                }
                            }
                        }
                    }
                }
            }
        }
        return measurements
    }
}
