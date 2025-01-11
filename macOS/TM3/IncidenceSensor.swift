import Foundation

struct IncidenceSensor {
    let id: String?
    let placemark: String?
    let location: Location
    let incidence: [Incidence]
    let timestamp: Date?
}
