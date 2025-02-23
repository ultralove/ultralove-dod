import Foundation

class IncidenceService {
    static func fetchDistricts(for location: Location) async throws -> Data? {
        let query =
            """
            [out:json][timeout:25];
            relation(around:30000,\(location.latitude),\(location.longitude))["boundary"="administrative"]["admin_level"~"4|6|9"];
            out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }

    static func fetchIncidence(id: String) async throws -> Data? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(id)/history/incidence/100") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }
}
