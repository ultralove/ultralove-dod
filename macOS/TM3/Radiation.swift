import Foundation

struct Radiation: Identifiable {
    let id = UUID()
    let total: Measurement<UnitRadiation>
    let timestamp: Date
}
