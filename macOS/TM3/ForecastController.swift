import CoreLocation
import Foundation
import WeatherKit

class ForecastController {
    func refreshForecast(for location: Location) async throws -> ForecastSensor? {
        let weather = try await WeatherService.shared.weather(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
        let forecast = weather.hourlyForecast.forecast.map {
            Forecast(temperature: $0.temperature, apparentTemperature: $0.apparentTemperature, timestamp: $0.date)
        }
        if let placemark = await LocationController.reverseGeocodeLocation(location: location) {
            return ForecastSensor(id: "<Unknown>", placemark: placemark, location: location, measurements: Array(forecast.prefix(7 * 24)), timestamp: Date.now)
        }
        return nil
    }
}
