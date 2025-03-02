import Foundation

class IncidenceService {
    static func fetchDistricts(for location: Location, radius: Double) async throws -> Data? {
        let query =
            """
            [out:json][timeout:25];
            relation(around:\(radius),\(location.latitude),\(location.longitude))["boundary"="administrative"]["admin_level"~"4|6|7|8|9"];
            out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        trace.debug("Fetching covid measurement districts...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched covid measurement districts.")
        return data
    }

    static func fetchIncidence(id: String) async throws -> Data? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(id)/history/incidence/100") else {
            return nil
        }
        trace.debug("Fetching covid incidence measurements...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched covid incidence measurements.")
        return data
    }

    static func fetchCases(id: String) async throws -> Data? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(id)/history/cases/100") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }

    static func fetchDeaths(id: String) async throws -> Data? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(id)/history/deaths/100") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }

    static func fetchRecovered(id: String) async throws -> Data? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(id)/history/recovered/100") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }
}
