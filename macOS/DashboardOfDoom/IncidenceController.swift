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
            var measurements: [IncidenceSelector: [ProcessValue<Dimension>]] = [:]
            if let incidence = try await self.fetchIncidence(for: district) {
                measurements[.incidence] = incidence
            }
            if let cases = try await self.fetchCases(for: district) {
                measurements[.cases] = cases
            }
            if let placemark = await LocationManager.reverseGeocodeLocation(location: district.location) {
                sensor = IncidenceSensor(
                    id: district.name, placemark: placemark, location: district.location, measurements: measurements, timestamp: Date.now)
            }
        }
        return sensor
    }

    static private func parseDistricts(data: Data) async throws -> [District]? {
        var districts: [District]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["elements"] as? [[String: Any]] {
                var nearestDistricts: [District] = []
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
        if let data = try await IncidenceService.fetchDistricts(for: location) {
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

    static private func parseIncidence(data: Data, district: District) throws -> [ProcessValue<Dimension>]? {
        var incidence: [ProcessValue<Dimension>]?
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let data = json["data"] as? [String: Any] {
                if let district = data[district.id] as? [String: Any] {
                    if let history = district["history"] as? [[String: Any]] {
                        for entry in history {
                            if let value = entry["weekIncidence"] as? Double {
                                if let dateString = entry["date"] as? String {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                                    if let date = dateFormatter.date(from: dateString) {
                                        let newIncidence = ProcessValue<Dimension>(
                                            value: Measurement<Dimension>(value: value, unit: UnitIncidence.casesPer100k), quality: .good,
                                            timestamp: date)
                                        if incidence == nil {
                                            incidence = [newIncidence]
                                        }
                                        else {
                                            incidence?.append(
                                                ProcessValue<Dimension>(
                                                    value: Measurement<Dimension>(value: value, unit: UnitIncidence.casesPer100k), quality: .good,
                                                    timestamp: date))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return incidence
    }

    private func fetchIncidence(for district: District) async throws -> [ProcessValue<Dimension>]? {
        var incidence: [ProcessValue<Dimension>]? = nil
        if let data = try await IncidenceService.fetchIncidence(id: district.id) {
            if let measurements = try Self.parseIncidence(data: data, district: district) {
                incidence = measurements
                if let current = Self.nowCast(data: incidence, alpha: 0.33) {
                    incidence?.append(current)
                    if let forecast = await Self.forecast(data: incidence) {
                        incidence?.append(contentsOf: forecast)
                    }
                }
            }
        }
        return incidence
    }

    static private func parseCases(data: Data, district: District) throws -> [ProcessValue<Dimension>]? {
        var incidence: [ProcessValue<Dimension>]?
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let _ = json["data"] as? [String: Any] {
                incidence = []
                //TODO: Implement parsing of case data
            }
        }
        return incidence
    }

    private func fetchCases(for district: District) async throws -> [ProcessValue<Dimension>]? {
        var cases: [ProcessValue<Dimension>]? = nil
        if let data = try await IncidenceService.fetchCases(id: district.id) {
            if let measurements = try Self.parseCases(data: data, district: district) {
                cases = measurements
                if let current = Self.nowCast(data: cases, alpha: 0.33) {
                    cases?.append(current)
                    if let forecast = await Self.forecast(data: cases) {
                        cases?.append(contentsOf: forecast)
                    }
                }
            }
        }
        return cases
    }


    private static func nowCast(data: [ProcessValue<Dimension>]?, alpha: Double) -> ProcessValue<Dimension>? {
        guard let data = data, data.count > 0, alpha >= 0.0, alpha <= 1.0 else {
            return nil
        }
        let historicalData = [ProcessValue<Dimension>](data.reversed())
        if let current = historicalData.max(by: { $0.timestamp < $1.timestamp }) {
            if let timestamp = Calendar.current.date(byAdding: .day, value: 1, to: current.timestamp) {
                let value = Self.nowCast(data: historicalData[1].value, previous: historicalData[0].value, alpha: alpha)
                return ProcessValue<Dimension>(value: value, quality: .uncertain, timestamp: timestamp)
            }
        }
        return nil
    }

    private static func nowCast(
        data: Measurement<Dimension>, previous: Measurement<Dimension>, alpha: Double
    ) -> Measurement<Dimension> {
        let value = alpha * data.value + (1 - alpha) * previous.value
        return Measurement<Dimension>(value: value, unit: data.unit)
    }

    private static func forecast(data: [ProcessValue<Dimension>]?) async -> [ProcessValue<Dimension>]? {
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
            let prediction = try predictor.forecast(duration: 42 * 24 * 3600)  // 42 days
            forecast = prediction.forecasts.map { forecast in
                ProcessValue<Dimension>(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
            }
        }
        catch {
            print("Forecasting error: \(error)")
        }
        return forecast
    }
}
