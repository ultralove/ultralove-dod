import Foundation

class FascismSensor : Sensor {
    let measurements: [String:[Fascism]]

    init(id: String?, placemark: String?, location: Location, measurements: [String:[Fascism]], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }
}

