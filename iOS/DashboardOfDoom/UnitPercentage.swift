import Foundation

class UnitPercentage: Dimension {
    static let percent = UnitPercentage(symbol: "%", converter: UnitConverterLinear(coefficient: 1.0))
    static let permille = UnitPercentage(symbol: "‰", converter: UnitConverterLinear(coefficient: 0.1))

    override class func baseUnit() -> Self {
        return percent as! Self
    }
}


