import Foundation

private struct Poll {
    let id: Int
    let parliament: Int
    let institute: Int
    let results: [Int: Double]
    let timestamp: Date
}

private struct Constituency {
    let name: String
    let location: Location
}

private struct Parliament {
    let id: Int
    let name: String
}

struct SurveyDescriptor {
    let shortcut: String
    let name: String
}

class SurveyController {
    private let germany = Constituency(name: "Deutschland", location: Location(latitude: 51.1600585, longitude: 10.4473544))

    let officialFascists = [7, 9, 11, 14, 16, 22, 25]
    let realFascists = [1, 7, 8, 9, 11, 14, 16, 22, 25, 101, 102]
    let officialClowns = [3]
    let realClowns = [3, 18, 23]
    let cducsu = [1, 101, 102]
    let afd = [7]
    let fdp = [3]
    let bsw = [23]

    func refreshFederalSurveys(for location: Location) async throws -> SurveySensor? {
        var sensor: SurveySensor? = nil
        let sensorName = germany.name
        let sensorLocation = germany.location
        let parliamentId = 0  // Bundestag

        if let data = try await SurveyService.fetchPolls() {
            if let polls = try await parsePolls(from: data, for: parliamentId) {
                let sortedPolls = polls.sorted { $0.timestamp > $1.timestamp }
                if sortedPolls.count > 0 {
                    let significantPolls = Array(sortedPolls.prefix(47).reversed())
                    var measurements: [SurveySelector: [Survey]] = [:]

                    var values: [Survey] = []
                    for poll in significantPolls {
                        let measurement = Measurement(value: computeShare(self.realFascists, from: poll), unit: UnitPercentage.percent)
                        let fascism = Survey(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                        values.append(fascism)
                    }
                    if values.count > 0 {
                        measurements[.fascists] = values
                    }

                    values.removeAll(keepingCapacity: true)
                    for poll in significantPolls {
                        let measurement = Measurement(value: computeShare(self.realClowns, from: poll), unit: UnitPercentage.percent)
                        let fascism = Survey(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                        values.append(fascism)
                    }
                    if values.count > 0 {
                        measurements[.clowns] = values
                    }

                    let descriptors = try await parseParties(from: data)
                    for (selector, _) in descriptors {
                        values.removeAll(keepingCapacity: true)
                        for poll in significantPolls {
                            let measurement = Measurement(value: computeShare([selector.rawValue], from: poll), unit: UnitPercentage.percent)
                            let fascism = Survey(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                            values.append(fascism)
                        }
                        if values.count > 0 {
                            measurements[selector] = values
                        }
                    }

                    if let placemark = await LocationManager.reverseGeocodeLocation(location: sensorLocation) {
                        sensor = SurveySensor(
                            id: sensorName, placemark: placemark, location: sensorLocation, measurements: measurements, timestamp: Date.now)
                    }
                }
            }
        }
        return sensor
    }

    func refreshLocalSurveys(for location: Location) async throws -> SurveySensor? {
        var sensor: SurveySensor? = nil
        var sensorName = germany.name
        var sensorLocation = germany.location
        var parliamentId = 0  // Bundestag

        if let constituency = try await Self.fetchConstituency(location: location) {
            if let data = try await SurveyService.fetchPolls() {
                if let parliaments = try await parseParliaments(from: data) {
                    for parliament in parliaments where parliament.name.contains(constituency.name) {
                        sensorName = constituency.name
                        sensorLocation = constituency.location
                        parliamentId = parliament.id
                        break
                    }
                }
            }
        }
        
        if let data = try await SurveyService.fetchPolls() {
            if let polls = try await parsePolls(from: data, for: parliamentId) {
                let sortedPolls = polls.sorted { $0.timestamp > $1.timestamp }
                if sortedPolls.count > 0 {
                    let significantPolls = Array(sortedPolls.prefix(47).reversed())
                    var measurements: [SurveySelector: [Survey]] = [:]

                    var values: [Survey] = []
                    for poll in significantPolls {
                        let measurement = Measurement(value: computeShare(self.realFascists, from: poll), unit: UnitPercentage.percent)
                        let fascism = Survey(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                        values.append(fascism)
                    }
                    if values.count > 0 {
                        measurements[.fascists] = values
                    }

                    values.removeAll(keepingCapacity: true)
                    for poll in significantPolls {
                        let measurement = Measurement(value: computeShare(self.realClowns, from: poll), unit: UnitPercentage.percent)
                        let fascism = Survey(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                        values.append(fascism)
                    }
                    if values.count > 0 {
                        measurements[.clowns] = values
                    }

                    let descriptors = try await parseParties(from: data)
                    for (selector, _) in descriptors {
                        values.removeAll(keepingCapacity: true)
                        for poll in significantPolls {
                            let measurement = Measurement(value: computeShare([selector.rawValue], from: poll), unit: UnitPercentage.percent)
                            let fascism = Survey(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                            values.append(fascism)
                        }
                        if values.count > 0 {
                            measurements[selector] = values
                        }
                    }

                    if let placemark = await LocationManager.reverseGeocodeLocation(location: sensorLocation) {
                        sensor = SurveySensor(
                            id: sensorName, placemark: placemark, location: sensorLocation, measurements: measurements, timestamp: Date.now)
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
        if let data = try await SurveyService.fetchStates(for: location) {
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

    private func computeShare(_ selector: [Int], from poll: Poll) -> Double {
        var score = 0.0
        let fascists = selector
        for fascist in fascists {
            if let result = poll.results[fascist] {
                score += result
            }
        }
        return score
    }

    private func parseParliaments(from data: Data) async throws -> [Parliament]? {
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

    private func parseParties(from data: Data) async throws -> [SurveySelector: SurveyDescriptor] {
        var parties: [SurveySelector: SurveyDescriptor] = [:]
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["Parties"] as? [String: Any] {
                parties = [:]
                for element in elements {
                    if let id = Int(element.key) {
                        if let selector = SurveySelector(rawValue: id) {
                            if let party = elements[element.key] as? [String: Any] {
                                if let shortcut = party["Shortcut"] as? String {
                                    if let name = party["Name"] as? String {
                                        parties[selector] = SurveyDescriptor(shortcut: shortcut, name: name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return parties
    }

    private func parseInstitues(from data: Data) async throws -> [Int: String]? {
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

    private func parsePolls(from data: Data, for parliament: Int) async throws -> [Poll]? {
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
