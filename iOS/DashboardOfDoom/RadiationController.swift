import Foundation

class RadiationController {
    private static let endpoint =
        "https://www.imis.bfs.de/ogc/opendata/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=opendata:odlinfo_odl_1h_latest&outputFormat=application/json"

    func refreshRadiation(for location: Location) async throws -> RadiationSensor? {
        guard let url = URL(string: Self.endpoint) else { return nil }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        if let radiationSensors = try Self.parseRadiation(from: data) {
            return Self.nearestSensor(radiationSensors: radiationSensors, location: location)
        }
        return nil
    }

    private static func parseRadiation(from data: Data) throws -> [RadiationSensor]? {
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let features = json["features"] as? [[String: Any]] {
                var radiationSensors: [RadiationSensor] = []
                for feature in features {
                    if let geometry = feature["geometry"] as? [String: Any],
                        let coordinates = geometry["coordinates"] as? [Double]
                    {
                        if let properties = feature["properties"] as? [String: Any] {
                            if let name = properties["name"] as? String {
                                let siteStatus = properties["site_status"] as? Int
                                if siteStatus == 1 {
                                    let station = Location(name: name, latitude: coordinates[1], longitude: coordinates[0])
                                    let radiation = Radiation(
                                        id: properties["kenn"] as? String ?? "<Unknown>",
                                        total: Measurement(value: properties["value"] as? Double ?? Double.nan, unit: UnitRadiation.microsieverts),
                                        cosmic: Measurement(value: properties["value_cosmic"] as? Double ?? Double.nan, unit: UnitRadiation.microsieverts),
                                        terrestrial: Measurement(
                                            value: properties["value_terrestrial"] as? Double ?? Double.nan, unit: UnitRadiation.microsieverts))
                                    radiationSensors.append(RadiationSensor(station: station, radiation: radiation))
                                }
                            }
                        }
                    }
                }
                return radiationSensors
            }
        }
        return nil
    }

    private static func nearestSensor(radiationSensors: [RadiationSensor], location: Location) -> RadiationSensor? {
        var nearestSensor: RadiationSensor? = nil
        var minDistance = 1000.0  // (km) This is more than the distance from List to Oberstdorf (960km)
        for radiationSensor in radiationSensors {
            let distance = haversineDistance(location_0: radiationSensor.station, location_1: location)
            if distance < minDistance {
                minDistance = distance
                nearestSensor = radiationSensor
            }
        }
        return nearestSensor
    }

    func fetchShortTermHistory(for id: String, completion: @escaping @Sendable ([RadiationSensor]?) -> Void) {
        completion(nil)
    }

    func fetchLongTermHistory(for id: String, completion: @escaping @Sendable ([RadiationSensor]?) -> Void) {
        completion(nil)
    }
}


