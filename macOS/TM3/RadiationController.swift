import Foundation

struct RadiationStation {
    let id: String
    let name: String
    let location: Location
}

class RadiationController {
    func refreshRadiation(for location: Location) async throws -> RadiationSensor? {
        var sensor: RadiationSensor? = nil
        if let nearestStation = try await Self.fetchNearestStation(location: location) {
            if let measurements = try await Self.fetchMeasurements(station: nearestStation) {
                if let placemark = await LocationController.reverseGeocodeLocation(location: nearestStation.location) {
                    sensor = RadiationSensor(id: nearestStation.name, placemark: placemark, location: nearestStation.location, measurements: measurements, timestamp: Date.now)
                }
            }
        }
        return sensor
    }

    private static func fetchNearestStation(location: Location) async throws -> RadiationStation? {
        var nearestStation: RadiationStation? = nil
        if let data = try await BfSAPI.fetchStations() {
            let stations = try await Self.parseStations(from: data)
            if stations.count > 0 {
                nearestStation = Self.nearestStation(stations: stations, location: location)
            }
        }
        return nearestStation
    }

    private static func parseStations(from data: Data) async throws -> [RadiationStation] {
        var stations: [RadiationStation] = []
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let features = json["features"] as? [[String: Any]] {
                for feature in features {
                    if let geometry = feature["geometry"] as? [String: Any], let coordinates = geometry["coordinates"] as? [Double] {
                        let location = Location(latitude: coordinates[1], longitude: coordinates[0])
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
        var radiation: [Radiation]? = nil
        if let data = try await BfSAPI.fetchMeasurements(for: station.id) {
            radiation = try Self.parseRadiation(data: data)
        }
        return radiation
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
