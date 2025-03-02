import Foundation

class LevelSensor : Sensor {
    let measurements: [ProcessValue<Dimension>]

    init(id: String?, placemark: String?, location: Location, measurements: [ProcessValue<Dimension>], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }

    init(id: String?, placemark: String?, customData: [String: Any], location: Location, measurements: [ProcessValue<Dimension>], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, customData: customData, location: location, timestamp: timestamp)
    }
}

