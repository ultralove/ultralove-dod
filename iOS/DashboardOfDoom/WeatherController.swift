import CoreLocation
import Foundation
import WeatherKit

class WeatherController {
    func refreshWeather(for location: Location) async throws -> WeatherSensor? {
        let weather = try await WeatherService.shared.weather(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
        return WeatherSensor(
            location: location,
            weather: Weather(
                temperature: weather.currentWeather.temperature, apparentTemperature: weather.currentWeather.apparentTemperature,
                conditionsSymbol: weather.currentWeather.symbolName))
    }
}
