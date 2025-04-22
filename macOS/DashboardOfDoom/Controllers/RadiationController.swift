import Foundation

class RadiationController: ProcessController {
    private let measurementDistance: TimeInterval
    private let forecastDuration: TimeInterval

    init() {
        self.measurementDistance = 3600  // 1 hour
        self.forecastDuration = 1 * 24 * self.measurementDistance  // 1 day
    }

    func refreshData(for location: Location) async throws -> ProcessSensor? {
        var sensor: ProcessSensor? = nil
        if let nearestStation = try await Self.fetchNearestStation(location: location) {
            var measurements: [ProcessSelector: [ProcessValue<Dimension>]] = [:]
            if let radiation = try await Self.fetchMeasurements(station: nearestStation) {
                var measurement: [ProcessValue<Dimension>] = []
                measurement.append(contentsOf: Self.interpolateMeasurements(measurements: radiation, distance: self.measurementDistance))
                measurement.append(contentsOf: Self.forecastMeasurements(data: measurement, duration: self.forecastDuration))
                measurements[.radiation(.total)] = measurement.sorted(by: { $0.timestamp < $1.timestamp })
            }
            if let placemark = await LocationManager.reverseGeocodeLocation(location: nearestStation.location) {
                sensor = ProcessSensor(
                    name: nearestStation.name, location: nearestStation.location, placemark: placemark, customData: ["icon": "atom"], measurements: measurements,
                    timestamp: Date.now)
            }
        }
        return sensor
    }

    struct Station {
        let id: String
        let name: String
        let location: Location
    }

    private static func fetchNearestStation(location: Location) async throws -> Station? {
        var nearestStation: Station? = nil
        if let data = try await RadiationService.fetchStations() {
            let stations = try await Self.parseStations(from: data)
            if stations.count > 0 {
                nearestStation = Self.nearestStation(stations: stations, location: location)
            }
        }
        return nearestStation
    }

    private static func parseStations(from data: Data) async throws -> [Station] {
        var stations: [Station] = []
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let features = json["features"] as? [[String: Any]] {
                for feature in features {
                    if let geometry = feature["geometry"] as? [String: Any], let coordinates = geometry["coordinates"] as? [Double] {
                        let location = Location(latitude: coordinates[1], longitude: coordinates[0])
                        if let properties = feature["properties"] as? [String: Any] {
                            if let id = properties["kenn"] as? String {
                                if let name = properties["name"] as? String {
                                    let siteStatus = properties["site_status"] as? Int
                                    if siteStatus == 1 {
                                        stations.append(Station(id: id, name: name, location: location))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return stations
    }

    private static func nearestStation(stations: [Station], location: Location) -> Station? {
        var nearestStation: Station? = nil
        var minDistance = Measurement(value: 1000.0, unit: UnitLength.kilometers)  // This is more than the distance from List to Oberstdorf (960km)
        for station in stations {
            let distance = haversineDistance(location_0: station.location, location_1: location)
            if distance < minDistance {
                minDistance = distance
                nearestStation = station
            }
        }
        return nearestStation
    }

    private static func fetchMeasurements(station: Station) async throws -> [ProcessValue<Dimension>]? {
        var radiation: [ProcessValue<Dimension>]? = nil
        if let data = try await RadiationService.fetchMeasurements(for: station.id) {
            radiation = try Self.parseRadiation(data: data)
        }
        return radiation
    }

    private static func parseRadiation(data: Data) throws -> [ProcessValue<Dimension>] {
        var measurements: [ProcessValue<Dimension>] = []
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let features = json["features"] as? [[String: Any]] {
                for feature in features {
                    if let properties = feature["properties"] as? [String: Any] {
                        if let dateString = properties["end_measure"] as? String {
                            let isoFormatter = ISO8601DateFormatter()
                            if let timestamp = isoFormatter.date(from: dateString) {
                                if let value = properties["value"] as? Double {
                                    let measurement = ProcessValue<Dimension>(
                                        value: Measurement(value: value, unit: UnitRadiation.microsieverts), quality: .good, timestamp: timestamp)
                                    measurements.append(measurement)
                                }
                            }
                        }
                    }
                }
            }
        }
        return measurements
    }

    private static func interpolateMeasurements(measurements: [ProcessValue<Dimension>], distance: TimeInterval) -> [ProcessValue<Dimension>] {
        var interpolated: [ProcessValue<Dimension>] = []
        if let start = measurements.first?.timestamp, let end = measurements.last?.timestamp {
            let unit = measurements[0].value.unit
            var current = start
            if var last = measurements.first {
                while current <= end {
                    if let match = measurements.first(where: { $0.timestamp == current }) {
                        last = match
                        interpolated.append(match)
        }
                    else {
                        interpolated
                            .append(
                                ProcessValue<Dimension>(
                                    value: Measurement(value: last.value.value, unit: unit), quality: .uncertain,
                                    timestamp: current))
                    }
                    current = current.addingTimeInterval(distance)
                }
            }
        }
        return interpolated
    }

    private static func forecastMeasurements(data: [ProcessValue<Dimension>], duration: TimeInterval) -> [ProcessValue<Dimension>] {
        var forecast: [ProcessValue<Dimension>] = []
        if data.count > 0 {
            let unit = data[0].value.unit
            let dataPoints = data.map { incidence in
            TimeSeriesPoint(timestamp: incidence.timestamp, value: incidence.value.value)
        }
        let predictor = ARIMAPredictor(parameters: ARIMAParameters(p: 2, d: 1, q: 1), interval: .hourly)
        do {
                try predictor.addData(dataPoints)
                let prediction = try predictor.forecast(duration: duration)  
            forecast = prediction.forecasts.map { forecast in
                ProcessValue<Dimension>(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
            }
        }
        catch {
                trace.error("Forecasting error: %@", error.localizedDescription)
            }
        }
        return forecast
    }
}
