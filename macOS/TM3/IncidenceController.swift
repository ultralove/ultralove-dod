import Foundation

struct District: Identifiable, Equatable {
    let id: String
    let name: String
    let location: Location
}

class IncidenceController {
    func refreshIncidence(for location: Location) async throws -> IncidenceSensor? {
        if let district = try await self.fetchDistrict(for: location) {
            if let (incidence, name) = try await self.fetchIncidence(for: district) {
                let incidenceSensor = IncidenceSensor(id: name, location: district.location, incidence: incidence, timestamp: Date.now)
                return incidenceSensor
            }
        }
        return nil
    }

    static private func parseDistricts(data: Data) throws -> [District]? {
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["elements"] as? [[String: Any]] {
                var districts: [District] = []
                for element in elements {
                    if let center = element["center"] as? [String: Any] {
                        if let latitude = center["lat"] as? Double, let longitude = center["lon"] as? Double {
                            if let tags = element["tags"] as? [String: Any] {
                                if let name = tags["name"] as? String {
                                    if let id = tags["de:regionalschluessel"] as? String {
                                        if id.count >= 5 {
//                                            let district = District(id: String(id.prefix(5)), name: name, latitude: latitude, longitude: longitude)
                                            let district = District(id: String(id.prefix(5)), name: name, location: Location(name: name, latitude: latitude, longitude: longitude))
                                            districts.append(district)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                return districts
            }
        }
        return nil
    }

    private func fetchDistrict(for location: Location) async throws -> District? {
        let query =
            """
            [out:json][timeout:100];
            relation(around:30000,\(location.latitude),\(location.longitude))["boundary"="administrative"]["admin_level"~"4|6|9"];
            out center tags;
            """
        guard let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(query)") else { return nil }

        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        if let candidateDistricts: [District] = try Self.parseDistricts(data: data) {
            var nearestDistrict: District? = nil
            var minDistance = Measurement(value: 1000.0, unit: UnitLength.kilometers)  // This is more than the distance from List to Oberstdorf (960km)
            for candidateDistrict in candidateDistricts {
                let candidateLocation = candidateDistrict.location
                let distance = haversineDistance(location_0: candidateLocation, location_1: location)
                if distance < minDistance {
                    minDistance = distance
                    nearestDistrict = candidateDistrict
                }
            }
            return nearestDistrict
        }
        return nil
    }

    static private func parseIncidence(data: Data, district: District) throws -> ([Incidence], String)? {
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let data = json["data"] as? [String: Any] {
                if let district = data[district.id] as? [String: Any] {
                    if let name = district["name"] as? String {
                        if let history = district["history"] as? [[String: Any]] {
                            var incidence: [Incidence] = []
                            for entry in history {
                                if let value = entry["weekIncidence"] as? Double {
                                    if let dateString = entry["date"] as? String {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                        dateFormatter.timeZone = TimeZone.current
                                        if let date = dateFormatter.date(from: dateString) {
                                            incidence.append(Incidence(value: value, quality: .good, timestamp: date))
                                        }
                                    }
                                }
                            }
                            if let forecast = Self.nowCast(data: incidence, count: incidence.count - 1, alpha: 0.33) {
                                incidence += forecast
                            }
                            return (incidence, name)
                        }
                    }
                }
            }
        }
        return nil
    }

    private func fetchIncidence(for district: District) async throws -> ([Incidence], String)? {
        guard let url = URL(string: "https://api.corona-zahlen.org/districts/\(district.id)/history/incidence/100") else { return nil }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return try Self.parseIncidence(data: data, district: district)
    }

    private static func nowCast(data: [Incidence]?, count: Int, alpha: Double) -> [Incidence]? {
        guard let data = data, data.count > 0, count > 0, count < data.count, alpha >= 0.0, alpha <= 1.0 else {
            return nil
        }
        let historicalData = [Incidence](data.reversed().prefix(count + 1))
        if let start = historicalData.first?.timestamp.addingTimeInterval(60 * 60 * 24) {
            if var forecastData = Self.initializeForecast(from: start, count: count) {
                let value = Self.nowCast(data: historicalData[1].value, previous: historicalData[0].value, alpha: alpha)
                let incidence = Incidence(value: value, quality: .uncertain, timestamp: forecastData[0].timestamp)
                forecastData[0] = incidence
//                for i in 1 ..< count {
//                    forecastData[i].incidence = Self.nowCast(data: historicalData[i + 1].incidence, previous: forecastData[i - 1].incidence, alpha: alpha)
//                }
                return forecastData
            }
        }
        return nil
    }

    private static func nowCast(data: Double, previous: Double, alpha: Double) -> Double {
        return alpha * data + (1 - alpha) * previous
    }

    private static func initializeForecast(from: Date, count: Int) -> [Incidence]? {
        guard count > 0 else {
            return nil
        }
        var forecast: [Incidence] = []
        for i in 0 ..< count {
            if let forecastDate = Self.initializeForecastDate(from: from.addingTimeInterval(60 * 60 * 24 * Double(i))) {
                forecast.append(Incidence(value: 0, quality: .unknown, timestamp: forecastDate))
            }
        }
        return forecast
    }

    private static func initializeForecastDate(from: Date) -> Date? {
        var components = DateComponents()
        components.year = Calendar.current.component(.year, from: from)
        components.month = Calendar.current.component(.month, from: from)
        components.day = Calendar.current.component(.day, from: from)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone.current
        return Calendar.current.date(from: components)
    }
}
