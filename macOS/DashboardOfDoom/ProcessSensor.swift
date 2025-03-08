import Foundation

class ProcessSensor {
    let id: String
    let location: Location
    var placemark: String?
    var customData: [String: Any]?
    let measurements: [ProcessSelector: [ProcessValue<Dimension>]]
    let timestamp: Date?

    init(id: String, location: Location, measurements: [ProcessSelector: [ProcessValue<Dimension>]], timestamp: Date?) {
        self.id = id
        self.location = location
        self.measurements = measurements
        self.timestamp = timestamp
    }

    init(id: String, location: Location, placemark: String?, measurements: [ProcessSelector: [ProcessValue<Dimension>]], timestamp: Date?) {
        self.id = id
        self.location = location
        self.placemark = placemark
        self.measurements = measurements
        self.timestamp = timestamp
    }

    init(id: String, location: Location, placemark: String?, customData: [String: Any]?, measurements: [ProcessSelector: [ProcessValue<Dimension>]], timestamp: Date?) {
        self.id = id
        self.location = location
        self.placemark = placemark
        self.customData = customData
        self.measurements = measurements
        self.timestamp = timestamp
    }
}
