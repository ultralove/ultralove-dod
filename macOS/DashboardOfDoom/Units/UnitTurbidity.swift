import Foundation

class UnitTurbidity: Dimension, @unchecked Sendable {
    static let fnu = UnitTurbidity(
        symbol: "FNU",
        converter: UnitConverterLinear(coefficient: 1.0) // FNU as base unit
    )

    // If you plan to add NTU later, choose a consistent base unit (e.g., FNU or NTU)
    override class func baseUnit() -> Self {
        return fnu as! Self
    }
}
