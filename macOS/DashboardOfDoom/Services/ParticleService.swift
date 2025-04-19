import Foundation

class ParticleService {
    static func fetchStations(from: Date, to: Date) async throws -> Data? {
        let hour = Calendar.current.component(.hour, from: from)
        let endpoint = String(
            format:
                "https://www.umweltbundesamt.de/api/air_data/v3/stations/json?use=airquality&lang=en&date_from=%@&time_from=%d&date_to=%@&time_to=%d",
            from.dateString(), hour, to.dateString(), hour)
        if let url = URL(string: endpoint) {
            trace.debug("Fetching particle measurement stations...")
            let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
            trace.debug("Fetched particle measurement stations.")
            return data
        }
        return nil
    }

    static func fetchMeasurements(code: String, from: Date, to: Date) async throws -> Data? {
        let hour = Calendar.current.component(.hour, from: from)
        let endpoint = String(
            format:
                "https://www.umweltbundesamt.de/api/air_data/v3/airquality/json?date_from=%@&time_from=%d&date_to=%@&time_to=%d&station=%@",
            from.dateString(), hour, to.dateString(), hour, code)
        if let url = URL(string: endpoint) {
            trace.debug("Fetching particle measurements...")
            let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
            trace.debug("Fetched particle measurements.")
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
            trace.debug("Fetching particle measurement forecasts...")
            let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
            trace.debug("Fetched particle measurement forecasts.")
            return data
        }
        return nil
    }
}
