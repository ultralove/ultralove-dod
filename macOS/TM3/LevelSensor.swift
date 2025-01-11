import Foundation

struct LevelSensor {
    let id: String?
    let placemark: String?
    let location: Location
    let measurements: [Level]
    let timestamp: Date?
}

