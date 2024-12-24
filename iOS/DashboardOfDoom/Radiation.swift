import Foundation

struct Radiation: Sendable {
   let id: String
   let total: Measurement<UnitRadiation>
   let cosmic: Measurement<UnitRadiation>?
   let terrestrial: Measurement<UnitRadiation>?
}
