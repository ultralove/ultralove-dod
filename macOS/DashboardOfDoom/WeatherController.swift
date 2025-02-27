import CoreLocation
import Foundation
import WeatherKit

class WeatherController {
    func refreshWeather(for location: Location) async throws -> WeatherSensor? {
        let weather = try await WeatherService.shared.weather(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
        if let placemark = await LocationManager.reverseGeocodeLocation(latitude: location.latitude, longitude: location.longitude) {
        return WeatherSensor(
                id: nil, placemark: placemark, location: location,
                measurements: Weather(
                temperature: weather.currentWeather.temperature, apparentTemperature: weather.currentWeather.apparentTemperature,
                    symbol: weather.currentWeather.symbolName), timestamp: Date.now)
        }
        return nil
    }
}
