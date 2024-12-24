import Foundation

struct Forecast: Identifiable, Sendable {
   let id = UUID()
   var date: Date
   var temperature: Measurement<UnitTemperature>
   var apparentTemperature: Measurement<UnitTemperature>?
}

