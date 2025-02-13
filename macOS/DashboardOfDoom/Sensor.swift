import Foundation

class Sensor {
    let id: String?
    let placemark: String?
    let location: Location
    let timestamp: Date?

    init(id: String?, placemark: String?, location: Location, timestamp: Date?) {
        self.id = id
        self.placemark = placemark
        self.location = location
        self.timestamp = timestamp
    }
}
