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

struct Descriptor {
    let shortcut: String
    let name: String
}

class SurveyController: ProcessController {
    private let germany = Constituency(name: "Deutschland", location: Location(latitude: 51.1600585, longitude: 10.4473544))

    let officialFascists: [ProcessSelector] = [
        .survey(.afd), .survey(.npd), .survey(.bayernpartei), .survey(.bvb_fw), .survey(.biw), .survey(.bfth), .survey(.bsw), .survey(.werte_union)
    ]
    let realFascists: [ProcessSelector] = [
        .survey(.cducsu), .survey(.afd), .survey(.freie_waehler), .survey(.npd), .survey(.bayernpartei), .survey(.bvb_fw), .survey(.biw),
        .survey(.bfth), .survey(.bsw), .survey(.werte_union), .survey(.cdu), .survey(.csu)
    ]
    let officialClowns: [ProcessSelector] = [.survey(.fdp)]
    let realClowns: [ProcessSelector] = [.survey(.fdp), .survey(.volt)]

    func refreshData(for location: Location) async throws -> ProcessSensor? {
        return try await self.refreshFederalSurveys(for: location)
    }

    private func refreshFederalSurveys(for location: Location) async throws -> ProcessSensor? {
        var sensor: ProcessSensor? = nil
        let sensorName = germany.name
        let sensorLocation = germany.location
        let parliamentId = 0  // Bundestag

        if let data = try await SurveyService.fetchPolls() {
            if let polls = try await parsePolls(from: data, for: parliamentId) {
                let sortedPolls = polls.sorted { $0.timestamp > $1.timestamp }
                if sortedPolls.count > 0 {
                    let significantPolls = Array(sortedPolls.prefix(167).reversed())
                    var measurements: [ProcessSelector: [ProcessValue<Dimension>]] = [:]

                    var values: [ProcessValue<Dimension>] = []
                    for poll in significantPolls {
                        let measurement = Measurement<Dimension>(value: Self.computeShare(self.realFascists, from: poll), unit: UnitPercentage.percent)
                        let fascism = ProcessValue<Dimension>(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                        values.append(fascism)
                    }
                    if values.count > 0 {
                        measurements[.survey(.fascists)] = values
                    }

                    values.removeAll(keepingCapacity: true)
                    for poll in significantPolls {
                        let measurement = Measurement<Dimension>(value: Self.computeShare(self.realClowns, from: poll), unit: UnitPercentage.percent)
                        let fascism = ProcessValue<Dimension>(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                        values.append(fascism)
                    }
                    if values.count > 0 {
                        measurements[.survey(.clowns)] = values
                    }

                    let constraints = [
                        ProcessSelector.survey(.linke).rawValue,
                        ProcessSelector.survey(.gruene).rawValue,
                        ProcessSelector.survey(.spd).rawValue,
                        ProcessSelector.survey(.afd).rawValue,
                        ProcessSelector.survey(.fdp).rawValue,
                        ProcessSelector.survey(.bsw).rawValue,
                        ProcessSelector.survey(.cducsu).rawValue
                    ]
                    let descriptors = try await parseParties(from: data, constraints: constraints)
                    for (selector, _) in descriptors {
                        values.removeAll(keepingCapacity: true)
                        for poll in significantPolls {
                            let measurement = Measurement<Dimension>(
                                value: Self.computeShare([selector], from: poll), unit: UnitPercentage.percent)
                            let fascism = ProcessValue<Dimension>(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                            values.append(fascism)
                        }
                        if values.count > 0 {
                            measurements[selector] = values
                        }
                    }

                    measurements = await self.interpolateMeasurements(measurements: await self.aggregateMeasurements(measurements: measurements))
                    if let placemark = await LocationManager.reverseGeocodeLocation(location: sensorLocation) {
                        sensor = ProcessSensor(
                            name: sensorName, location: sensorLocation, placemark: placemark, customData: ["icon": "popcorn"],
                            measurements: measurements, timestamp: Date.now)
                    }
                }
            }
        }
        return sensor
    }

    private func refreshLocalSurveys(for location: Location) async throws -> ProcessSensor? {
        var sensor: ProcessSensor? = nil
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
                    var measurements: [ProcessSelector: [ProcessValue<Dimension>]] = [:]

                    var values: [ProcessValue<Dimension>] = []
                    for poll in significantPolls {
                        let measurement = Measurement<Dimension>(value: Self.computeShare(self.realFascists, from: poll), unit: UnitPercentage.percent)
                        let fascism = ProcessValue<Dimension>(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                        values.append(fascism)
                    }
                    if values.count > 0 {
                        measurements[.survey(.fascists)] = values
                    }

                    values.removeAll(keepingCapacity: true)
                    for poll in significantPolls {
                        let measurement = Measurement<Dimension>(value: Self.computeShare(self.realClowns, from: poll), unit: UnitPercentage.percent)
                        let fascism = ProcessValue<Dimension>(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                        values.append(fascism)
                    }
                    if values.count > 0 {
                        measurements[.survey(.clowns)] = values
                    }

                    let descriptors = try await parseParties(from: data, constraints: [])
                    for (selector, _) in descriptors {
                        values.removeAll(keepingCapacity: true)
                        for poll in significantPolls {
                            let measurement = Measurement<Dimension>(
                                value: Self.computeShare([selector], from: poll), unit: UnitPercentage.percent)
                            let fascism = ProcessValue<Dimension>(value: measurement, quality: .uncertain, timestamp: poll.timestamp)
                            values.append(fascism)
                        }
                        if values.count > 0 {
                            measurements[selector] = values
                        }
                    }

                    if let placemark = await LocationManager.reverseGeocodeLocation(location: sensorLocation) {
                        sensor = ProcessSensor(
                            name: sensorName, location: sensorLocation, placemark: placemark, measurements: measurements, timestamp: Date.now)
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

    private static func computeShare(_ selectors: [ProcessSelector], from poll: Poll) -> Double {
        var score = 0.0
        for selector in selectors {
            let index: Int = selector.rawValue
            if let result = poll.results[index] {
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

    private func parseParties(from data: Data, constraints: [Int]) async throws -> [ProcessSelector: Descriptor] {
        var parties: [ProcessSelector: Descriptor] = [:]
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["Parties"] as? [String: Any] {
                parties = [:]
                for element in elements {
                    if let id = Int(element.key) {
                        if constraints.contains(id) {
                        if let selector = ProcessSelector.Survey(rawValue: id) {
                                if let party = elements[element.key] as? [String: Any] {
                                    if let shortcut = party["Shortcut"] as? String {
                                        if let name = party["Name"] as? String {
                                            parties[.survey(selector)] = Descriptor(shortcut: shortcut, name: name)
                                        }
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
                                                                Poll(
                                                                    id: id, parliament: parliamentId, institute: instituteId, results: results,
                                                                    timestamp: timestamp))
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

    private func interpolateMeasurements(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) async -> [ProcessSelector: [ProcessValue<Dimension>]] {
        var interpolatedMeasurements: [ProcessSelector: [ProcessValue<Dimension>]] = [:]
        for (selector, measurement) in measurements {
            interpolatedMeasurements[selector] = await self.interpolateMeasurement(measurements: measurement)
        }
        return interpolatedMeasurements
    }

    private func interpolateMeasurement(measurements: [ProcessValue<Dimension>]) async -> [ProcessValue<Dimension>] {
        var interpolatedMeasurement: [ProcessValue<Dimension>] = []
        if let start = measurements.first?.timestamp, let end = measurements.last?.timestamp {
            var current = start
            if var last = measurements.first {
                while current <= end {
                    if let match = measurements.first(where: { $0.timestamp == current }) {
                        last = match
                        interpolatedMeasurement.append(match)
                    }
                    else {
                        interpolatedMeasurement
                            .append(
                                ProcessValue<Dimension>(
                                    value: Measurement(value: last.value.value, unit: UnitPercentage.percent), quality: .uncertain,
                                    timestamp: current))
                    }
                    current = current.addingTimeInterval(60 * 60 * 24)
                }
            }
        }
        if let forecast = Self.forecast(data: interpolatedMeasurement, duration: 31) {
            interpolatedMeasurement.append(contentsOf: forecast)
        }
        return interpolatedMeasurement
    }

    private func aggregateMeasurements(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) async -> [ProcessSelector: [ProcessValue<Dimension>]] {
        var aggregatedMeasurements: [ProcessSelector: [ProcessValue<Dimension>]] = [:]
        for (selector, measurement) in measurements {
            let uniqueMeasurements = Dictionary(grouping: measurement) { $0.timestamp }
                .map { timestamp, values in
                    self.aggregateMeasurement(timestamp: timestamp, measurements: values, quality: .uncertain)
                }.sorted(by: { $0.timestamp < $1.timestamp })
            aggregatedMeasurements[selector] = uniqueMeasurements
        }
        return aggregatedMeasurements
    }

    private func aggregateMeasurement(timestamp: Date, measurements: [ProcessValue<Dimension>], quality: ProcessQuality) -> ProcessValue<Dimension> {
        let value = measurements.map(\.value.value).reduce(0, +) / Double(measurements.count)
        let unit = measurements.count > 0 ? measurements[0].value.unit : UnitPercentage.percent // Use hardcoded unit if no measurements are available
        return ProcessValue<Dimension>(value: Measurement<Dimension>(value: value, unit: unit), quality: quality, timestamp: timestamp)
    }

    private static func forecast(data: [ProcessValue<Dimension>]?, duration: TimeInterval) -> [ProcessValue<Dimension>]? {
        var forecast: [ProcessValue<Dimension>]? = nil
        guard let historicalData = data, historicalData.count > 0 else {
            return nil
        }
        let unit = historicalData[0].value.unit
        let historicalDataPoints = historicalData.map { incidence in
            TimeSeriesPoint(timestamp: incidence.timestamp, value: incidence.value.value)
        }
        let predictor = ARIMAPredictor(parameters: ARIMAParameters(p: 2, d: 1, q: 1), interval: .daily)
        do {
            try predictor.addData(historicalDataPoints)
            let prediction = try predictor.forecast(duration: duration * 24 * 60 * 60)  // days
            forecast = prediction.forecasts.map { forecast in
                ProcessValue<Dimension>(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
            }
        }
        catch {
            trace.error("Forecasting error: \(error)")
        }
        return forecast
    }

}
