import CoreLocation
import Foundation
import WeatherKit

class ForecastController {
    func refreshForecast(for location: Location) async throws -> ForecastSensor? {
        let weather = try await WeatherService.shared.weather(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
        let forecast = weather.hourlyForecast.forecast.map {
            Forecast(date: $0.date, temperature: $0.temperature, apparentTemperature: $0.apparentTemperature)
        }
        return ForecastSensor(location: location, forecast: forecast, timestamp: Date.now)
    }
}
