import Foundation

class FascismSensor : Sensor {
    let measurements: [Fascism]

    init(id: String?, placemark: String?, location: Location, measurements: [Fascism], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }
}

