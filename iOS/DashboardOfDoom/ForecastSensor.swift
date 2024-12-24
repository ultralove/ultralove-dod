import Foundation

struct ForecastSensor: Sendable {
   let location: Location
   let forecast: [Forecast]
}
