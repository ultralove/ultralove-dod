import Foundation

struct Level: Identifiable {
    let id = UUID()
    let measurement: Measurement<UnitLength>
    let timestamp: Date
}

