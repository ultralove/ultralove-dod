import Foundation

class UnitAcidity: Dimension, @unchecked Sendable {
    static let pH = UnitAcidity(
        symbol: "pH",
        converter: UnitConverterLinear(coefficient: 1.0) // dimensionless
    )

    override class func baseUnit() -> Self {
        return pH as! Self
    }
}


