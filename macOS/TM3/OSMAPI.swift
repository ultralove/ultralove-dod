import Foundation

class OSMAPI {
    static func fetchDistricts(for location: Location) async throws -> Data? {
        let query =
            """
            [out:json][timeout:100];
            relation(around:30000,\(location.latitude),\(location.longitude))["boundary"="administrative"]["admin_level"~"4|6|9"];
            out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }

    //[out:json][timeout:25];
    //(
    //    way["waterway"="river"]["ref"~"."](around:50000,52.5186,13.3643);
    //    relation["waterway"="river"]["ref"~"."](around:50000,52.5186,13.3643);
    //    way["waterway"="canal"]["ref"~"."](around:50000,52.5186,13.3643);
    //    relation["waterway"="canal"]["ref"~"."](around:50000,52.5186,13.3643);
    //);
    //out center tags;

    //way["waterway"="dam"]["ref"~"."](around:300000,52.5186,13.3643);
    //relation["waterway"="dam"]["ref"~"."](around:300000,52.5186,13.3643);

    //way["waterway"~"^(river|canal|dam|fairway)$"]["ref"~"."](around:300000,52.5186,13.3643);
    //relation["waterway"~"^(river|canal|dam|fairway)$"]["ref"~"."](around:300000,52.5186,13.3643);

    //way["waterway"~"^(river|canal)$"]["ref"~"."](around:50000,52.5186,13.3643);
    //relation["waterway"~"^(river|cancel)$"]["ref"~"."](around:50000,52.5186,13.3643);

    //-------------------------------------------------------------------------------
//    [out:json][timeout:25];
//    (
//        way["waterway"~"^(river|stream|canal)$"]["ref"~"."](around:50000,52.5186,13.3643);
//        relation["waterway"~"^(river|stream|canal)$"]["ref"~"."](around:50000,52.5186,13.3643);
//    );
//    out center tags;
    //-------------------------------------------------------------------------------
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
