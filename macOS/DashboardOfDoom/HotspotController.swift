import Foundation

class Hotspot: Identifiable {
    let id = UUID()
    let name: String
    let location: Location

    init(name: String, location: Location) {
        self.name = name
        self.location = location
    }
}

class HotspotController {
//    private let radius = 2666.67
    private let radius = 6666.67

    func fetchPharmacies(location: Location) async -> [Hotspot]? {
        var pharmacies: [Hotspot]? = nil
        do {
            if let data = try await HotspotService.fetchPharmacies(location: location, radius: self.radius) {
                pharmacies = try Self.parseHotspots(from: data)
            }
        }
        catch {
            trace.error("Error fetching pharmacies: %@", error.localizedDescription)
        }
        return pharmacies
    }

    func fetchHospitals(location: Location) async -> [Hotspot]? {
        var hospitals: [Hotspot]? = nil
        do {
            if let data = try await HotspotService.fetchHospitals(location: location, radius: self.radius) {
                hospitals = try Self.parseHotspots(from: data)
            }
        }
        catch {
            trace.error("Error fetching hospitals: %@", error.localizedDescription)
        }
        return hospitals
    }

    func fetchLiquorStores(location: Location) async -> [Hotspot]? {
        var liquorStores: [Hotspot]? = nil
        do {
            if let data = try await HotspotService.fetchLiquorStores(location: location, radius: self.radius) {
                liquorStores = try Self.parseHotspots(from: data)
            }
        }
        catch {
            trace.error("Error fetching liquor stores: %@", error.localizedDescription)
        }
        return liquorStores
    }

    func fetchFuneralDirectors(location: Location) async -> [Hotspot]? {
        var funeralDirectors: [Hotspot]? = nil
        do {
            if let data = try await HotspotService.fetchFuneralDirectors(location: location, radius: self.radius) {
                funeralDirectors = try Self.parseHotspots(from: data)
            }
        }
        catch {
            trace.error("Error fetching funeral directors: %@", error.localizedDescription)
        }
        return funeralDirectors
    }

    func fetchCemeteries(location: Location) async -> [Hotspot]? {
        var cemeteries: [Hotspot]? = nil
        do {
            if let data = try await HotspotService.fetchCemeteries(location: location, radius: self.radius) {
                cemeteries = try Self.parseHotspots(from: data)
            }
        }
        catch {
            trace.error("Error fetching cemeteries: %@", error.localizedDescription)
        }
        return cemeteries
    }

    private static func parseHotspots(from data: Data) throws -> [Hotspot]? {
        var hotspots: [Hotspot]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["elements"] as? [[String: Any]] {
                for element in elements {
                    if let type = element["type"] as? String {
                        if type == "node" {
                            if let latitude = element["lat"] as? Double, let longitude = element["lon"] as? Double {
                                if let tags = element["tags"] as? [String: Any] {
                                    if let name = tags["name"] as? String {
                                        let hotspot = Hotspot(name: name, location: Location(latitude: latitude, longitude: longitude))
                                        if hotspots == nil {
                                            hotspots = [hotspot]
                                        }
                                        else {
                                            hotspots?.append(hotspot)
                                        }
                                    }
                                }
                            }
                        }
                        else if type == "way" {
                            if let center = element["center"] as? [String: Any] {
                                if let latitude = center["lat"] as? Double, let longitude = center["lon"] as? Double {
                                    if let tags = element["tags"] as? [String: Any] {
                                        if let name = tags["name"] as? String {
                                            let hotspot = Hotspot(name: name, location: Location(latitude: latitude, longitude: longitude))
                                            if hotspots == nil {
                                                hotspots = [hotspot]
                                            }
                                            else {
                                                hotspots?.append(hotspot)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return hotspots
    }
}
