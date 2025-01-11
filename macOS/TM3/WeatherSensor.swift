import Foundation

struct WeatherSensor {
    var id: String?
    var placemark: String?
    var location: Location
    var weather: Weather
    let timestamp: Date?
}
