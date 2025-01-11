import Foundation

struct Weather {
    let temperature: Measurement<UnitTemperature>
    let apparentTemperature: Measurement<UnitTemperature>
    let humidity: Double
    let pressure: Measurement<UnitPressure>
    let symbol: String
}
