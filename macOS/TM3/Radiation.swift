import Foundation

struct Radiation {
   let id: String
   let total: Measurement<UnitRadiation>
   let cosmic: Measurement<UnitRadiation>?
   let terrestrial: Measurement<UnitRadiation>?
}
