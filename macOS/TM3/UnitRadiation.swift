import Foundation

class UnitRadiation: Dimension {
   // Define units for radiation
   static let sieverts = UnitRadiation(symbol: "Sv/h", converter: UnitConverterLinear(coefficient: 1.0))
   static let millisieverts = UnitRadiation(symbol: "mSv/h", converter: UnitConverterLinear(coefficient: 0.001))
   static let microsieverts = UnitRadiation(symbol: "µSv/h", converter: UnitConverterLinear(coefficient: 0.000001))
   static let grays = UnitRadiation(symbol: "Gy/h", converter: UnitConverterLinear(coefficient: 1.0)) // Optional: Gray unit
   
   // Return the base unit for radiation
   override class func baseUnit() -> Self {
      return sieverts as! Self
   }
}
