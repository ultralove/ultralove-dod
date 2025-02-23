import CoreLocation
import Foundation
import WeatherKit

class ForecastController {
    func refreshForecast(for location: Location) async throws -> ForecastSensor? {
        let weather = try await WeatherService.shared.weather(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
        let forecast = weather.hourlyForecast.forecast.prefix(100)
        let actual = forecast.map {
            Forecast(value: Measurement(value: $0.temperature.value, unit: $0.temperature.unit), quality: .uncertain, timestamp: $0.date)
        }
        let apparent = forecast.map {
            Forecast(value: Measurement(value: $0.apparentTemperature.value, unit: $0.temperature.unit), quality: .uncertain, timestamp: $0.date)
        }
        let dewPoint = forecast.map {
            Forecast(value: Measurement(value: $0.dewPoint.value, unit: $0.dewPoint.unit), quality: .uncertain, timestamp: $0.date)
        }
        let humidity = forecast.map {
            Forecast(value: Measurement(value: $0.humidity * 100, unit: UnitPercentage.percent), quality: .uncertain, timestamp: $0.date)
        }
        let precipitationChance = forecast.map {
            Forecast(
                value: Measurement(value: $0.precipitationChance * 100, unit: UnitPercentage.percent), quality: .uncertain, timestamp: $0.date)
        }
        let precipitationAmount = forecast.map {
            Forecast(
                value: Measurement(value: $0.precipitationAmount.value, unit: $0.precipitationAmount.unit), quality: .uncertain, timestamp: $0.date
            )
        }
        let pressure = forecast.map {
            Forecast(value: Measurement(value: $0.pressure.value, unit: $0.pressure.unit), quality: .uncertain, timestamp: $0.date)
        }
        let visibility = forecast.map {
            Forecast(value: Measurement(value: $0.visibility.value, unit: $0.visibility.unit), quality: .uncertain, timestamp: $0.date)
        }
        if let placemark = await LocationManager.reverseGeocodeLocation(location: location) {
            var measurements: [ForecastSelector: [Forecast]] = [:]
            measurements[.actual] = actual
            measurements[.apparent] = apparent
            measurements[.dewPoint] = dewPoint
            measurements[.humidity] = humidity
            measurements[.precipitationChance] = precipitationChance
            measurements[.precipitationAmount] = precipitationAmount
            measurements[.pressure] = pressure
            measurements[.visibility] = visibility
            return ForecastSensor(id: nil, placemark: placemark, location: location, measurements: measurements, timestamp: Date.now)
        }
        return nil
    }
}
