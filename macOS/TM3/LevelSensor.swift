import Foundation

class LevelSensor : Sensor {
    let measurements: [Level]

    init(id: String?, placemark: String?, location: Location, measurements: [Level], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }
}

