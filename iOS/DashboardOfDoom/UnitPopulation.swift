import Foundation

class UnitPopulation: Dimension {
    static let people = UnitPopulation(
        symbol: "n",
        converter: UnitConverterLinear(coefficient: 1.0)
    )

    static let thousand = UnitPopulation(
        symbol: "k",
        converter: UnitConverterLinear(coefficient: 1000.0)
    )

    static let million = UnitPopulation(
        symbol: "M",
        converter: UnitConverterLinear(coefficient: 1000000.0)
    )

    override class func baseUnit() -> Self {
        return people as! Self
    }
}
