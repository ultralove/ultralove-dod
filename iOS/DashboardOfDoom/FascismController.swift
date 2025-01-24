import Foundation

struct Poll {
    let id: Int
    let parliament: Int
    let institute: Int
    let results: [Int: Double]
    let timestamp: Date
}

struct Constituency {
    let name: String
    let location: Location
}

struct Parliament {
    let id: Int
    let name: String
}

class FascismController {
    let germany = Constituency(name: "Deutschland", location: Location(latitude: 51.1600585, longitude: 10.4473544))

    func refreshFascism(for location: Location) async throws -> FascismSensor? {
        var sensor: FascismSensor? = nil
        let sensorName = germany.name
        let sensorLocation = germany.location
        let parliamentId = 0  // Bundestag
        if let data = try await DAWUMAPI.fetchPolls() {
            if let polls = try await parsePolls(from: data, for: parliamentId) {
                let sortedPolls = polls.sorted { $0.timestamp > $1.timestamp }
                if sortedPolls.count > 0 {
                    let significantPolls = Array(sortedPolls.reversed())
                    var measurements: [Fascism] = []
                    for poll in significantPolls {
                        let measurement = Measurement<UnitPercentage>(value: computeFascism(from: poll), unit: .percent)
                        let fascism = Fascism(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                        measurements.append(fascism)
                    }
                    if measurements.count > 0 {
                        if let placemark = await LocationController.reverseGeocodeLocation(location: sensorLocation) {
                            sensor = FascismSensor(
                                id: sensorName, placemark: placemark, location: location, measurements: measurements, timestamp: Date.now)
                        }
                    }
                }
            }
        }

        return sensor
    }

    func refreshLocalFascism(for location: Location) async throws -> FascismSensor? {
        var sensor: FascismSensor? = nil
        var sensorName = germany.name
        var sensorLocation = germany.location
        var parliamentId = 0  // Bundestag
        if let constituency = try await Self.fetchConstituency(location: location) {
            if let data = try await DAWUMAPI.fetchPolls() {
                if let parliaments = try await parseParliaments(from: data) {
                    for parliament in parliaments where parliament.name.contains(constituency.name) {
                        sensorName = constituency.name
                        sensorLocation = constituency.location
                        parliamentId = parliament.id
                        break
                    }
                }
                if let polls = try await parsePolls(from: data, for: parliamentId) {
                    let sortedPolls = polls.sorted { $0.timestamp > $1.timestamp }
                    if sortedPolls.count > 0 {
                        let significantPolls = Array(sortedPolls.reversed())
                        var measurements: [Fascism] = []
                        for poll in significantPolls {
                            let measurement = Measurement<UnitPercentage>(value: computeFascism(from: poll), unit: .percent)
                            let fascism = Fascism(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                            measurements.append(fascism)
                        }
                        if measurements.count > 0 {
                            if let placemark = await LocationController.reverseGeocodeLocation(location: sensorLocation) {
                                sensor = FascismSensor(
                                    id: sensorName, placemark: placemark, location: location, measurements: measurements, timestamp: Date.now)
                            }
                        }
                    }
                }
            }
        }
        return sensor
    }

    private static func parseConstituencies(data: Data) async throws -> [Constituency]? {
        var constituencies: [Constituency]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["elements"] as? [[String: Any]] {
                var nearestConstituencies: [Constituency] = []
                for element in elements {
                    if let center = element["center"] as? [String: Any] {
                        if let latitude = center["lat"] as? Double, let longitude = center["lon"] as? Double {
                            if let tags = element["tags"] as? [String: Any] {
                                if let name = tags["name"] as? String {
                                    let location = Location(latitude: latitude, longitude: longitude)
                                    nearestConstituencies.append(Constituency(name: name, location: location))
                                }
                            }
                        }
                    }
                }
                constituencies = nearestConstituencies
            }
        }
        return constituencies
    }

    private static func fetchConstituency(location: Location) async throws -> Constituency? {
        var nearestConstituency: Constituency? = nil
        if let data = try await OSMAPI.fetchStates(for: location) {
            if let candidateConstituencies = try await Self.parseConstituencies(data: data) {
                var minDistance = Measurement(value: 1000.0, unit: UnitLength.kilometers)  // This is more than the distance from List to Oberstdorf (960km)
                for candidateConstituency in candidateConstituencies {
                    let candidateLocation = candidateConstituency.location
                    let distance = haversineDistance(location_0: candidateLocation, location_1: location)
                    if distance < minDistance {
                        minDistance = distance
                        nearestConstituency = candidateConstituency
                    }
                }
            }
        }
        return nearestConstituency
    }

    func computeFascism(from poll: Poll) -> Double {
        var score = 0.0
        //  1: Christlich Demokratische Union / Christlich-Soziale Union
        //  7: Alternative für Deutschland
        //  8: Freie Wähler
        //  9: Nationaldemokratische Partei Deutschlands
        // 11: Bayernpartei e.V.
        // 14: Brandenburger Vereinigte Bürgerbewegungen/Freie Wähler
        // 16: Bürger in Wut
        // 17: Familienpartei Deutschlands
        // 22: Bürger für Thüringen
        // 23: Bündnis Sahra Wagenknecht
        // 25: WerteUnion
        // 101: Christlich Demokratische Union
        // 102: Christlich-Soziale Union
        let fascists = [1, 7, 8, 9, 11, 14, 16, 17, 22, 23, 25, 101, 102]
        for fascist in fascists {
            if let result = poll.results[fascist] {
                score += result
            }
        }
        return score
    }

    func parseParliaments(from data: Data) async throws -> [Parliament]? {
        var parliaments: [Parliament]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["Parliaments"] as? [String: Any] {
                parliaments = []
                for element in elements {
                    if let id = Int(element.key) {
                        if let found = elements[element.key] as? [String: Any] {
                            if let name = found["Shortcut"] as? String {
                                parliaments?.append(Parliament(id: id, name: name))
                            }
                        }
                    }
                }
            }
        }
        return parliaments
    }

    func parseParties(from data: Data) async throws -> [Int: String]? {
        var parties: [Int: String]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["Parties"] as? [String: Any] {
                parties = [:]
                for element in elements {
                    if let id = Int(element.key) {
                        if let party = elements[element.key] as? [String: Any] {
                            if let name = party["Shortcut"] as? String {
                                parties?[id] = name
                            }
                        }
                    }
                }
            }
        }
        return parties
    }

    func parseInstitues(from data: Data) async throws -> [Int: String]? {
        var institutes: [Int: String]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["Institutes"] as? [String: Any] {
                institutes = [:]
                for element in elements {
                    if let id = Int(element.key) {
                        if let institute = elements[element.key] as? [String: Any] {
                            if let name = institute["Name"] as? String {
                                institutes?[id] = name
                            }
                        }
                    }
                }
            }
        }
        return institutes
    }

    func parsePolls(from data: Data, for parliament: Int) async throws -> [Poll]? {
        var polls: [Poll]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["Surveys"] as? [String: Any] {
                polls = []
                for element in elements {
                    if let id = Int(element.key) {
                        if let poll = elements[element.key] as? [String: Any] {
                            if let date = poll["Date"] as? String {
                                if let timestamp = Self.parseTimestamp(date: date) {
                                    if let parliamentString = poll["Parliament_ID"] as? String {
                                        if let parliamentId = Int(parliamentString) {
                                            if parliamentId == parliament {
                                                if let institute = poll["Institute_ID"] as? String {
                                                    if let instituteId = Int(institute) {
                                                        if let numbers = poll["Results"] as? [String: Double] {
                                                            var results: [Int: Double] = [:]
                                                            for result in numbers {
                                                                if let key = Int(result.key) {
                                                                    results[key] = result.value
                                                                }
                                                            }
                                                            polls?.append(
                                                                Poll(id: id, parliament: parliamentId, institute: instituteId, results: results, timestamp: timestamp))
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
                }
            }
        }
        return polls
    }

    private static func parseTimestamp(date: String) -> Date? {
        var timestamp: Date? = nil
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let formattedDate = dateFormatter.date(from: date) {
            timestamp = formattedDate
        }
        return timestamp
    }
}
