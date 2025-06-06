import Foundation

class LevelService {
    static func fetchStations() async throws -> Data? {
        let endpoint = "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations.json"
        guard let url = URL(string: endpoint) else {
            return nil
        }
        trace.debug("Fetching level measurements stations...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched level measurements stations.")
        return data
    }

    static func fetchWaterways(for location: Location, radius: Double) async throws -> Data? {
        let box = calculateBoundingBox(center: location, radiusInMeters: radius)
        let query =
            """
            [out:json][timeout:25][bbox:\(box.minLatitude),\(box.minLongitude),\(box.maxLatitude),\(box.maxLongitude)];
            (
            way(around:\(radius),\(location.latitude),\(location.longitude))["waterway"="river"];
            );
            out center tags qt;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        trace.debug("Fetching nearby waterways...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched nearby waterways.")
        return data
    }

    static func fetchMeasurements(for id: String) async throws -> Data? {
        let endpoint = String(format: "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations/%@/W/measurements.json?start=P3D", id)
        guard let url = URL(string: endpoint) else {
            return nil
        }
        trace.debug("Fetching level measurements...")
        trace.debug("Station: %@", id)
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched level measurements.")
        return data
    }

    static func fetchforecast(for id: String) async throws -> Data? {
        let endpoint = String(format: "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations/%@/WV/measurements.json", id)
        guard let url = URL(string: endpoint) else {
            return nil
        }
        trace.debug("Fetching level measurements forecast...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched level measurements forecast.")
        return data
    }
}
