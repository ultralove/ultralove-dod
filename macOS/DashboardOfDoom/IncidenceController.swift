import Foundation

struct District: Identifiable, Equatable {
    let id: String
    let name: String
    let location: Location
}

class IncidenceController {
    private let measurementDistance: TimeInterval
    private let forecastDuration: TimeInterval

    init() {
        self.measurementDistance = 24 * 60 * 60  // 1 day
        self.forecastDuration = 37 * self.measurementDistance  // 37 days
    }

    func refreshIncidence(for location: Location) async throws -> IncidenceSensor? {
        var sensor: IncidenceSensor? = nil
        if let district = try await self.fetchDistrict(for: location) {
            if let incidence = try await self.fetchIncidence(for: district) {
                var measurements: [ProcessValue<Dimension>] = []
                measurements.append(contentsOf: Self.interpolateMeasurements(measurements: incidence, distance: self.measurementDistance))
                measurements.append(contentsOf: Self.forecastMeasurements(data: incidence, duration: self.forecastDuration))
                if let placemark = await LocationManager.reverseGeocodeLocation(location: district.location) {
                    sensor = IncidenceSensor(
                        id: district.name, placemark: placemark, customData: ["icon": "facemask"], location: district.location,
                        measurements: measurements, timestamp: Date.now)
                }
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
        if let data = try await IncidenceService.fetchDistricts(for: location, radius: 30000) {
            if let candidateDistricts: [District] = try await Self.parseDistricts(data: data) {
                var minDistance = Measurement(value: 1000.0, unit: UnitLength.kilometers)  // This is more than the distance from List to Oberstdorf (960km)
                for candidateDistrict in candidateDistricts {
                    let candidateLocation = candidateDistrict.location
                    let distance = haversineDistance(location_0: candidateLocation, location_1: location).converted(to: .kilometers)
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
                }
            }
        }
        return incidence
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

    private static func interpolateMeasurements(measurements: [ProcessValue<Dimension>], distance: TimeInterval) -> [ProcessValue<Dimension>] {
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
                                    value: Measurement(value: last.value.value, unit: last.value.unit), quality: .uncertain,
                                    timestamp: current))
                    }
                    current = current.addingTimeInterval(distance)
                }
            }
        }
        return interpolatedMeasurement
    }

    private static func forecastMeasurements(data: [ProcessValue<Dimension>], duration: TimeInterval) -> [ProcessValue<Dimension>] {
        var forecastMeasurements: [ProcessValue<Dimension>] = []
        if data.count > 0 {
            let unit = data[0].value.unit
            let dataPoints = data.map { incidence in
                TimeSeriesPoint(timestamp: incidence.timestamp, value: incidence.value.value)
            }
            let predictor = ARIMAPredictor(parameters: ARIMAParameters(p: 2, d: 1, q: 1), interval: .daily)
            do {
                try predictor.addData(dataPoints)
                let prediction = try predictor.forecast(duration: duration)
                forecastMeasurements = prediction.forecasts.map { forecast in
                    ProcessValue<Dimension>(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
                }
            }
            catch {
                trace.error("Forecasting error: %@", error.localizedDescription)
            }
        }
        return forecastMeasurements
    }
}
