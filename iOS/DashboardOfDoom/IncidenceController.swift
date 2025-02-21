import Foundation

struct District: Identifiable, Equatable {
    let id: String
    let name: String
    let location: Location
}

class IncidenceController {
    func refreshIncidence(for location: Location) async throws -> IncidenceSensor? {
        var sensor: IncidenceSensor? = nil
        if let district = try await self.fetchDistrict(for: location) {
            if let incidence = try await self.fetchIncidence(for: district) {
                if let placemark = await LocationController.reverseGeocodeLocation(location: district.location) {
                    sensor = IncidenceSensor(id: district.name, placemark: placemark, location: district.location, measurements: incidence, timestamp: Date.now)
                }
            }
        }
        return sensor
    }

    static private func parseDistricts(data: Data) async throws -> [District]? {
        var districts: [District]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["elements"] as? [[String: Any]] {
                var nearestDistricts = [District]()
                for element in elements {
                    if let center = element["center"] as? [String: Any] {
                        if let latitude = center["lat"] as? Double, let longitude = center["lon"] as? Double {
                            if let tags = element["tags"] as? [String: Any] {
                                if let name = tags["name"] as? String {
                                    if let id = tags["de:regionalschluessel"] as? String {
                                        if id.count >= 5 {
                                            let location = Location(latitude: latitude, longitude: longitude)
                                            nearestDistricts.append(District(id: String(id.prefix(5)), name: name, location: location))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                districts = nearestDistricts
            }
        }
        return districts
    }

    private func fetchDistrict(for location: Location) async throws -> District? {
        var nearestDistrict: District? = nil
        if let data = try await OSMAPI.fetchDistricts(for: location) {
        if let candidateDistricts: [District] = try await Self.parseDistricts(data: data) {
            var minDistance = Measurement(value: 1000.0, unit: UnitLength.kilometers)  // This is more than the distance from List to Oberstdorf (960km)
            for candidateDistrict in candidateDistricts {
                let candidateLocation = candidateDistrict.location
                let distance = haversineDistance(location_0: candidateLocation, location_1: location)
                if distance < minDistance {
                    minDistance = distance
                    nearestDistrict = candidateDistrict
                }
            }
            }
        }
            return nearestDistrict
        }

    static private func parseIncidence(data: Data, district: District) throws -> [Incidence]? {
        var result: [Incidence]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let data = json["data"] as? [String: Any] {
                if let district = data[district.id] as? [String: Any] {
                        if let history = district["history"] as? [[String: Any]] {
                            var incidence: [Incidence] = []
                            for entry in history {
                                if let value = entry["weekIncidence"] as? Double {
                                    if let dateString = entry["date"] as? String {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                                        if let date = dateFormatter.date(from: dateString) {
                                            incidence.append(Incidence(value: Measurement<UnitIncidence>(value: value, unit: .casesPer100k), quality: .good, timestamp: date))
                                        }
                                    }
                                }
                            }
                            result = incidence
                            }
                        }
                    }
                }
        return result
        }

    private func fetchIncidence(for district: District) async throws -> [Incidence]? {
        var incidence: [Incidence]? = nil
        if let data = try await RKIAPI.fetchIncidence(id: district.id) {
            incidence = try Self.parseIncidence(data: data, district: district)
    }
        return incidence
    }
}
