import CoreLocation
import Foundation
import WeatherKit

class WeatherController {
    func refreshWeather(for location: Location) async throws -> WeatherSensor? {
        let weather = try await WeatherService.shared.weather(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
        let station = await LocationController.reverseGeocodeLocation(latitude: location.latitude, longitude: location.longitude) ?? "<Unknown>"
        return WeatherSensor(
            station: station,
            weather: Weather(
                temperature: weather.currentWeather.temperature, apparentTemperature: weather.currentWeather.apparentTemperature,
                humidity: weather.currentWeather.humidity, pressure: weather.currentWeather.pressure,
                conditionsSymbol: weather.currentWeather.symbolName), timestamp: Date.now)
    }
}
