import Foundation

struct Forecast: Identifiable {
   let id = UUID()
   let date: Date
   let temperature: Measurement<UnitTemperature>
   let apparentTemperature: Measurement<UnitTemperature>?
}

