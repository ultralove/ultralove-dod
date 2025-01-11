import Foundation

struct ForecastSensor {
    let id: String?
    let placemark: String?
    let location: Location
    let forecast: [Forecast]
    let timestamp: Date?
}
