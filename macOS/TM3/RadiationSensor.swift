import Foundation

struct RadiationSensor {
    let id: String?
    let location: Location
    let measurements: [Radiation]
    let timestamp: Date?
}
