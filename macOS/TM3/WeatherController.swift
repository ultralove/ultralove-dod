import CoreLocation
import Foundation
import WeatherKit

class WeatherController {
    func refreshWeather(for location: Location) async throws -> WeatherSensor? {
        let weather = try await WeatherService.shared.weather(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
        if let placemark = await LocationController.reverseGeocodeLocation(latitude: location.latitude, longitude: location.longitude) {
            return WeatherSensor(
                id: "current location", placemark: placemark, location: location,
                measurements: Weather(
                    temperature: weather.currentWeather.temperature, apparentTemperature: weather.currentWeather.apparentTemperature,
                    humidity: weather.currentWeather.humidity, pressure: weather.currentWeather.pressure,
                    symbol: weather.currentWeather.symbolName), timestamp: Date.now)
        }
        return nil
    }
}
