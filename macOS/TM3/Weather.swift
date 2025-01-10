import Foundation

struct Weather {
    var temperature: Measurement<UnitTemperature> = .init(value: 0.0, unit: .celsius)
    var apparentTemperature: Measurement<UnitTemperature> = .init(value: 0.0, unit: .celsius)
    var humidity: Double = 0.0
    var pressure: Measurement<UnitPressure> = .init(value: 0.0, unit: .hectopascals)

    var conditionsSymbol: String = ""
}
