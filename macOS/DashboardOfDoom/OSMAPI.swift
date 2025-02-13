import Foundation

class OSMAPI {
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

    static func fetchCountry(for location: Location) async throws -> Data? {
        let query =
            """
            [out:json][timeout:25];
            relation(around:10000,\(location.latitude),\(location.longitude))["boundary"="administrative"]["admin_level"="2"];
            out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }

    static func fetchObservedWaterways(for location: Location, radius: Double) async throws -> Data? {
        let query =
            """
            [out:json][timeout:25];
            (
            way["waterway"~"^(river|stream|canal)$"]["ref"~"."](around:\(radius),\(location.latitude),\(location.longitude));
            relation["waterway"~"^(river|stream|canal)$"]["ref"~"."](around:\(radius),\(location.latitude),\(location.longitude));
            );
            out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
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
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }
}
