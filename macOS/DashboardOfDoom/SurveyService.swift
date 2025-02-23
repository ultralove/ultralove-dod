import Foundation

class SurveyService {
    static func fetchStates(for location: Location) async throws -> Data? {
        let query =
            """
            [out:json][timeout:25];
            relation(around:10000,\(location.latitude),\(location.longitude))["boundary"="administrative"]["admin_level"="4"];
            out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }

    static func fetchPolls() async throws -> Data? {
        let endpoint = "https://api.dawum.de"
        guard let url = URL(string: endpoint) else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }
}
