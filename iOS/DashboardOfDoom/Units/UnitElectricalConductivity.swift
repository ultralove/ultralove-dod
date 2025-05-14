import Foundation

class UnitElectricalConductivity: Dimension, @unchecked Sendable {
    static let millisiemensPerCentimeter = UnitElectricalConductivity(
        symbol: "mS/cm",
        converter: UnitConverterLinear(coefficient: 0.1) // 1 mS/cm = 0.1 S/m
    )

    static let siemensPerMeter = UnitElectricalConductivity(
        symbol: "S/m",
        converter: UnitConverterLinear(coefficient: 1.0)
    )

    // Base unit is millisiemensPerCentimeter (mS/cm)
    override class func baseUnit() -> Self {
        return millisiemensPerCentimeter as! Self
    }
}

