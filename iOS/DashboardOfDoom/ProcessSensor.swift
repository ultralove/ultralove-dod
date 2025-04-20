import Foundation

class ProcessSensor: Identifiable {
    let id = UUID()
    let name: String
    let location: Location
    let placemark: String?
    let customData: [String: Any]?
    let measurements: [ProcessSelector: [ProcessValue<Dimension>]]
    let timestamp: Date?

    init(name: String, location: Location, measurements: [ProcessSelector: [ProcessValue<Dimension>]], timestamp: Date?) {
        self.name = name
        self.location = location
        self.placemark = nil
        self.customData = nil
        self.measurements = measurements
        self.timestamp = timestamp
    }

    init(name: String, location: Location, placemark: String?, measurements: [ProcessSelector: [ProcessValue<Dimension>]], timestamp: Date?) {
        self.name = name
        self.location = location
        self.placemark = placemark
        self.customData = nil
        self.measurements = measurements
        self.timestamp = timestamp
    }

    init(name: String, location: Location, placemark: String?, customData: [String: Any]?, measurements: [ProcessSelector: [ProcessValue<Dimension>]], timestamp: Date?) {
        self.name = name
        self.location = location
        self.placemark = placemark
        self.customData = customData
        self.measurements = measurements
        self.timestamp = timestamp
    }
}
