import Foundation

struct Forecast: Identifiable {
   let id = UUID()
    let temperature: Measurement<UnitTemperature>
    let apparentTemperature: Measurement<UnitTemperature>?
    let timestamp: Date
}
