import Foundation

class HotspotService {
    //[out:json][timeout:25];
    //(
    //    node["amenity"="pharmacy"](around:5000, 52.5199, 13.3652);
    //    way["amenity"="pharmacy"](around:5000, 52.5199, 13.3652);
    //)->.pharmacies;
    //.pharmacies out center tags;
    static func fetchPharmacies(location: Location, radius: Double) async throws -> Data? {
        let query =
            """
            [out:json][timeout:25];
            (
                node["amenity"="pharmacy"](around:\(radius),\(location.latitude),\(location.longitude));
                way["amenity"="pharmacy"](around:\(radius),\(location.latitude),\(location.longitude));
            )->.pharmacies;
            .pharmacies out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        trace.debug("Fetching nearby pharmacies...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched nearby pharmacies.")
        return data
    }

    //[out:json][timeout:25];
    //(
    //    node["amenity"="hospital"](around:5000, 52.5199, 13.3652);
    //    way["amenity"="hospital"](around:5000, 52.5199, 13.3652);
    //)->.hospitals;
    //.hospitals out center tags;
    static func fetchHospitals(location: Location, radius: Double) async throws -> Data? {
        let query =
            """
            [out:json][timeout:25];
            (
                node["amenity"="hospital"](around:\(radius),\(location.latitude),\(location.longitude));
                way["amenity"="hospital"](around:\(radius),\(location.latitude),\(location.longitude));
            )->.hospitals;
            .hospitals out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        trace.debug("Fetching nearby hospitals...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched nearby hospitals.")
        return data
    }

//    [out:json][timeout:25];
//    (
//        node["shop"="convenience"](around:5000, 52.5199, 13.3652);
//        way["shop"="convenience"](around:5000, 52.5199, 13.3652);
//        node["shop"="alcohol"](around:5000, 52.5199, 13.3652);
//        way["shop"="alcohol"](around:5000, 52.5199, 13.3652);
//        node["shop"="beverages"](around:5000, 52.5199, 13.3652);
//        way["shop"="beverages"](around:5000, 52.5199, 13.3652);
//    )->.spatis;
//    .spatis out center tags;
    static func fetchLiquorStores(location: Location, radius: Double) async throws -> Data? {
        let query =
            """
            [out:json][timeout:25];
            (
                node["shop"="convenience"](around:\(radius),\(location.latitude),\(location.longitude));
                way["shop"="convenience"](around:\(radius),\(location.latitude),\(location.longitude));
                node["shop"="alcohol"](around:\(radius),\(location.latitude),\(location.longitude));
                way["shop"="alcohol"](around:\(radius),\(location.latitude),\(location.longitude));
                node["shop"="beverages"](around:\(radius),\(location.latitude),\(location.longitude));
                way["shop"="beverages"](around:\(radius),\(location.latitude),\(location.longitude));
            )->.spatis;
            .spatis out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        trace.debug("Fetching nearby liquor stores...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched nearby liquor stores.")
        return data
    }

    //[out:json][timeout:25];
    //(
    //    node["shop"="funeral_directors"](around:5000, 52.5199, 13.3652);
    //    way["shop"="funeral_directors"](around:5000, 52.5199, 13.3652);
    //    node["amenity"="funeral_hall"](around:5000, 52.5199, 13.3652);
    //    way["amenity"="funeral_hall"](around:5000, 52.5199, 13.3652);
    //)->.funeral_homes;
    //.funeral_homes out center tags;
    static func fetchFuneralDirectors(location: Location, radius: Double) async throws -> Data? {
        let query =
            """
            [out:json][timeout:25];
            (
                node["shop"="funeral_directors"](around:\(radius),\(location.latitude),\(location.longitude));
                way["shop"="funeral_directors"](around:\(radius),\(location.latitude),\(location.longitude));
                node["amenity"="funeral_hall"](around:\(radius),\(location.latitude),\(location.longitude));
                way["amenity"="funeral_hall"](around:\(radius),\(location.latitude),\(location.longitude));
            )->.funeral_homes;
            .funeral_homes out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        trace.debug("Fetching nearby funeral directors...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched nearby funeral directors.")
        return data
    }

    //[out:json][timeout:25];
    //(
    //    way["landuse"="cemetery"](around:5000, 52.5199, 13.3652);
    //    way["amenity"="grave_yard"](around:5000, 52.5199, 13.3652);
    //)->.graveyards;
    //.graveyards out center tags;
    static func fetchCemeteries(location: Location, radius: Double) async throws -> Data? {
        let query =
            """
            [out:json][timeout:25];
            (
                way["landuse"="cemetery"](around:\(radius),\(location.latitude),\(location.longitude));
                way["amenity"="grave_yard"](around:\(radius),\(location.latitude),\(location.longitude));
            )->.graveyards;
            .graveyards out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else {
            return nil
        }
        trace.debug("Fetching nearby cemeteries...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched nearby cemeteries.")
        return data
    }
}


