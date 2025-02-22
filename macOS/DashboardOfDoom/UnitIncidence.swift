import Foundation

class UnitIncidence: Dimension {
    static let casesPer100k = UnitIncidence(
        symbol: "\u{2081}\u{2080}\u{2080}\u{2096}",
        converter: UnitConverterLinear(coefficient: 1.0)
    )

    static let casesPer1000k = UnitIncidence(
        symbol: "\u{2081}\u{2080}\u{2080}\u{2080}\u{2096}",
        converter: UnitConverterLinear(coefficient: 0.1)
    )

    override class func baseUnit() -> Self {
        return casesPer100k as! Self
    }
}
