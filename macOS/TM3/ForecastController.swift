import CoreLocation
import Foundation
import WeatherKit

class ForecastController {
    func refreshForecast(for location: Location) async throws -> ForecastSensor? {
        let weather = try await WeatherService.shared.weather(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
        let forecast = weather.hourlyForecast.forecast.map {
            Forecast(date: $0.date, temperature: $0.temperature, apparentTemperature: $0.apparentTemperature)
        }
        if let placemark = await LocationController.reverseGeocodeLocation(location: location) {
            return ForecastSensor(id: "<Unknown>", placemark: placemark, location: location, forecast: Array(forecast.prefix(7 * 24)), timestamp: Date.now)
        }
        return nil
    }
}
