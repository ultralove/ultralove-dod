import Foundation

class UBAAPI {
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

    static func fetchMeasurements(code: String) async throws -> Data? {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: Date.now)
        let hour = components.hour ?? 0
        var adjustedComponents = components
        adjustedComponents.minute = 0  // Reset minutes to 0
        adjustedComponents.second = 0  // Reset seconds to 0
        if let end = Calendar.current.date(from: adjustedComponents) {
            let start = end.addingTimeInterval((-1 * 21 * 24 * 60 * 60))  // rewind 21 days
            let endpoint = String(
                format:
                    "https://www.umweltbundesamt.de/api/air_data/v3/airquality/json?date_from=%@&time_from=%d&date_to=%@&time_to=%d&station=%@",
                start.dateString(), hour, end.dateString(), hour, code)
            if let url = URL(string: endpoint) {
                let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
                return data
            }
        }
        return nil
    }
}
