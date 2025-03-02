import CoreLocation
import Foundation
import WeatherKit

class WeatherController {
    func refreshWeather(for location: Location) async throws -> WeatherSensor? {
        var measurements: [WeatherSelector: ProcessValue<Dimension>] = [:]

        let weather = try await WeatherService.shared.weather(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
        let current = weather.currentWeather

        let cloudCover = Measurement<Dimension>(value: current.cloudCover * 100, unit: UnitPercentage.percent)
        measurements[.cloudCover] = ProcessValue(value: cloudCover, quality: .good)

        let dewPoint = Measurement<Dimension>(value: current.dewPoint.value, unit: current.dewPoint.unit)
        measurements[.dewPoint] = ProcessValue(value: dewPoint, quality: .good)

        let humidity = Measurement<Dimension>(value: current.humidity * 100, unit: UnitPercentage.percent)
        measurements[.humidity] = ProcessValue(value: humidity, quality: .good)

        let precipitationIntensity = Measurement<Dimension>(value: current.precipitationIntensity.value, unit: current.precipitationIntensity.unit)
        measurements[.precipitationIntensity] = ProcessValue(value: precipitationIntensity, quality: .good)

        let pressure = Measurement<Dimension>(value: current.pressure.value, unit: current.pressure.unit)
        measurements[.pressure] = ProcessValue(value: pressure, quality: .good)

        let actualTemperature = Measurement<Dimension>(value: current.temperature.value, unit: current.temperature.unit)
        measurements[.actualTemperature] = ProcessValue(value: actualTemperature, quality: .good)

        let apparentTemperature = Measurement<Dimension>(value: current.apparentTemperature.value, unit: current.apparentTemperature.unit)
        measurements[.apparentTemperature] = ProcessValue(value: apparentTemperature, quality: .good)

        let visibility = Measurement<Dimension>(value: current.visibility.value, unit: current.visibility.unit)
        measurements[.visibility] = ProcessValue(value: visibility, quality: .good)

        let windDirection = Measurement<Dimension>(value: current.wind.direction.value, unit: current.wind.direction.unit)
        measurements[.windDirection] = ProcessValue(value: windDirection, quality: .good)

        let windSpeed = Measurement<Dimension>(value: current.wind.speed.value, unit: current.wind.speed.unit)
        measurements[.windSpeed] = ProcessValue(value: windSpeed, quality: .good)

        if let gust = current.wind.gust {
            let windGust = Measurement<Dimension>(value: gust.value, unit: gust.unit)
            measurements[.windGust] = ProcessValue(value: windGust, quality: .good)
        }

        let customData: [String: Any] = ["icon": current.symbolName]

        if let placemark = await LocationManager.reverseGeocodeLocation(latitude: location.latitude, longitude: location.longitude) {
            return WeatherSensor(id: nil, placemark: placemark, location: location, measurements: measurements, customData: customData, timestamp: Date.now)
        }
        return nil
    }
}
