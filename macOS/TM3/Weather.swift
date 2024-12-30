import Foundation

struct Weather {
   var temperature: Measurement<UnitTemperature> = .init(value: 0.0, unit: .celsius)
   var apparentTemperature: Measurement<UnitTemperature> = .init(value: 0.0, unit: .celsius)
   var conditionsSymbol: String = ""
}
