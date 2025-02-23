import Foundation

class ParticleService {
    static func fetchStations() async throws -> Data? {
        guard
            let url = URL(
                string:
                    "https://www.umweltbundesamt.de/api/air_data/v3/stations/json?use=airquality&lang=en&date_from=2025-01-01&date_to=2025-02-17&time_from=9&time_to=9"
            )
        else {
            return nil
        }
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        return data
    }

    static func fetchMeasurements(code: String, from: Date, to: Date) async throws -> Data? {
        let hour = Calendar.current.component(.hour, from: from)
        let endpoint = String(
            format:
                "https://www.umweltbundesamt.de/api/air_data/v3/airquality/json?date_from=%@&time_from=%d&date_to=%@&time_to=%d&station=%@",
            from.dateString(), hour, to.dateString(), hour, code)
        if let url = URL(string: endpoint) {
            let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
            return data
        }
        return nil
    }

    static func fetchForecasts(code: String, from: Date, to: Date) async throws -> Data? {
        let hour = Calendar.current.component(.hour, from: from)
        let endpoint = String(
            format:
                "https://www.umweltbundesamt.de/api/air_data/v3/airqualityforecast/json?date_from=%@&time_from=%d&date_to=%@&time_to=%d&station=%@",
            from.dateString(), hour, to.dateString(), hour, code)
        if let url = URL(string: endpoint) {
            let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
            return data
        }
        return nil
    }
}
