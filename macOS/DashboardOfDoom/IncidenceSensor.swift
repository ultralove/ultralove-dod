import Foundation

class IncidenceSensor : Sensor {
    let measurements: [Incidence]

    init(id: String?, placemark: String?, location: Location, measurements: [Incidence], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }

}
