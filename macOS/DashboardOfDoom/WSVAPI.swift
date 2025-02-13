import Foundation

class WSVAPI {
    static func fetchStations() async throws -> Data? {
        let endpoint = "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations.json"
        guard let url = URL(string: endpoint) else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }

    static func fetchMeasurements(for id: String) async throws -> Data? {
        let endpoint = String(format: "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations/%@/W/measurements.json?start=P3D", id)
        guard let url = URL(string: endpoint) else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }
}
