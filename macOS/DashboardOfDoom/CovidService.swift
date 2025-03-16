import Foundation

class CovidService {
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

    static func fetchIncidence(id: String, duration: Double = 100.0) async throws -> Data? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(id)/history/incidence/\(Int(duration))") else {
            return nil
        }
        trace.debug("Fetching covid incidence measurements...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched covid incidence measurements.")
        return data
    }

    static func fetchCases(id: String, duration: Double = 100.0) async throws -> Data? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(id)/history/cases/\(Int(duration))") else {
            return nil
        }
        trace.debug("Fetching covid cases measurements...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched covid cases measurements.")
        return data
    }

    static func fetchDeaths(id: String, duration: Double = 100.0) async throws -> Data? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(id)/history/deaths/\(Int(duration))") else {
            return nil
        }
        trace.debug("Fetching covid deaths measurements...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched covid deaths measurements.")
        return data
    }

    static func fetchRecovered(id: String, duration: Double = 100.0) async throws -> Data? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(id)/history/recovered/\(Int(duration))") else {
            return nil
        }
        trace.debug("Fetching covid recovered measurements...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched covid recovered measurements.")
        return data
    }
}
