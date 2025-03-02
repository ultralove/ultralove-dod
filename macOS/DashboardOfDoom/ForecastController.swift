import CoreLocation
import Foundation
import WeatherKit

class ForecastController {
    func refreshForecast(for location: Location) async throws -> ForecastSensor? {
        if let placemark = await LocationManager.reverseGeocodeLocation(location: location) {
            var measurements: [ForecastSelector: [ProcessValue<Dimension>]] = [:]

            let weather = try await WeatherService.shared.weather(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
            let forecast = weather.hourlyForecast.forecast.prefix(111)

            let cloudCover = forecast.map {
                ProcessValue<Dimension>(value: Measurement(value: $0.cloudCover * 100, unit: UnitPercentage.percent), quality: .uncertain, timestamp: $0.date)
            }
            measurements[.cloudCover] = cloudCover

            let dewPoint = forecast.map {
                ProcessValue<Dimension>(value: Measurement(value: $0.dewPoint.value, unit: $0.dewPoint.unit), quality: .uncertain, timestamp: $0.date)
            }
            measurements[.dewPoint] = dewPoint

            let humidity = forecast.map {
                ProcessValue<Dimension>(value: Measurement(value: $0.humidity * 100, unit: UnitPercentage.percent), quality: .uncertain, timestamp: $0.date)
            }
            measurements[.humidity] = humidity

            let precipitationChance = forecast.map {
                ProcessValue<Dimension>(
                    value: Measurement(value: $0.precipitationChance * 100, unit: UnitPercentage.percent), quality: .uncertain, timestamp: $0.date)
            }
            measurements[.precipitationChance] = precipitationChance

            let precipitationAmount = forecast.map {
                ProcessValue<Dimension>(
                    value: Measurement(value: $0.precipitationAmount.value, unit: $0.precipitationAmount.unit), quality: .uncertain, timestamp: $0.date
                )
            }
            measurements[.precipitationAmount] = precipitationAmount

            let snowfallAmount = forecast.map {
                ProcessValue<Dimension>(value: Measurement(value: $0.snowfallAmount.value, unit: $0.snowfallAmount.unit), quality: .uncertain, timestamp: $0.date)
            }
            measurements[.snowfallAmount] = snowfallAmount

            let pressure = forecast.map {
                ProcessValue<Dimension>(value: Measurement(value: $0.pressure.value, unit: $0.pressure.unit), quality: .uncertain, timestamp: $0.date)
            }
            measurements[.pressure] = pressure

            let temperature = forecast.map {
                ProcessValue<Dimension>(
                    value: Measurement(value: $0.temperature.value, unit: $0.temperature.unit),
                    customData: ["icon": $0.symbolName], quality: .uncertain,
                    timestamp: $0.date
                )
            }
            measurements[.temperature] = temperature

            let apparentTemperature = forecast.map {
                ProcessValue<Dimension>(value: Measurement(value: $0.apparentTemperature.value, unit: $0.temperature.unit), quality: .uncertain, timestamp: $0.date)
            }
            measurements[.apparentTemperature] = apparentTemperature

            let visibility = forecast.map {
                ProcessValue<Dimension>(value: Measurement(value: $0.visibility.value, unit: $0.visibility.unit), quality: .uncertain, timestamp: $0.date)
            }
            measurements[.visibility] = visibility

            let windDirection = forecast.map {
                ProcessValue<Dimension>(value: Measurement(value: $0.wind.direction.value, unit: $0.wind.direction.unit), quality: .uncertain, timestamp: $0.date)
            }
            measurements[.windDirection] = windDirection

            let windSpeed = forecast.map {
                ProcessValue<Dimension>(value: Measurement(value: $0.wind.speed.value, unit: $0.wind.speed.unit), quality: .uncertain, timestamp: $0.date)
            }
            measurements[.windSpeed] = windSpeed

            let windGust = forecast.map {
                if let gust = $0.wind.gust {
                    ProcessValue<Dimension>(value: Measurement(value: gust.value, unit: gust.unit), quality: .uncertain, timestamp: $0.date)
                }
                else {
                    ProcessValue<Dimension>(value: Measurement(value: 0, unit: UnitSpeed.baseUnit()), quality: .unknown, timestamp: $0.date)
                }

            }
            measurements[.windGust] = windGust

            return ForecastSensor(id: nil, placemark: placemark, location: location, measurements: measurements, timestamp: Date.now)
        }

        return nil
    }
}
