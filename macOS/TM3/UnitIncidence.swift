import Foundation

import Foundation

class UnitIncidence: Dimension {
    // Define units for incidence
    static let casesper100k = UnitIncidence(symbol: "cases", converter: UnitConverterLinear(coefficient: 1.0))

    // Return the base unit for incidence
    override class func baseUnit() -> Self {
        return casesper100k as! Self
    }
}
