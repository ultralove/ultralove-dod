import Foundation

struct RadiationSensor {
    let station: String?
    let location: Location
    let measurements: [Radiation]
    let timestamp: Date?
}
