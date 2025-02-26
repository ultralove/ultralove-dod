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
        let query =
            """
            [out:json][timeout:25];
            (
            way(around:\(radius),\(location.latitude),\(location.longitude))["waterway"~"^(river|canal)$"];
            );
            out center tags;
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
        trace.debug("Fetching level measurements stations...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched level measurements stations.")
        return data
    }
}
