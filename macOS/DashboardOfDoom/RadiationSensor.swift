import Foundation

class RadiationSensor : Sensor {
    let measurements: [Radiation]

    init(id: String?, placemark: String?, location: Location, measurements: [Radiation], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }

    init(id: String?, placemark: String?, customData: [String: Any], location: Location, measurements: [Radiation], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, customData: customData, location: location, timestamp: timestamp)
    }
}
