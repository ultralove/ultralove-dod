import Foundation

struct IncidenceSensor {
    let id: String?
    let placemark: String?
    let location: Location
    let measurements: [Incidence]
    let timestamp: Date?
}
