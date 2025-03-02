import Foundation

class Sensor {
    let id: String?
    let placemark: String?
    var customData: [String: Any]?
    let location: Location
    let timestamp: Date?

    init(id: String?, placemark: String?, location: Location, timestamp: Date?) {
        self.id = id
        self.placemark = placemark
        self.customData = nil
        self.location = location
        self.timestamp = timestamp
    }

    init(id: String?, placemark: String?, customData: [String: Any]?, location: Location, timestamp: Date?) {
        self.id = id
        self.placemark = placemark
        self.customData = customData
        self.location = location
        self.timestamp = timestamp
    }
}
