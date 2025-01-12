import Foundation

struct ForecastSensor {
    let id: String?
    let placemark: String?
    let location: Location
    let measurements: [Forecast]
    let timestamp: Date?
}
