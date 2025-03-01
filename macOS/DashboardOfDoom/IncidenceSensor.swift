import Foundation

class IncidenceSensor: Sensor {
    let measurements: [IncidenceSelector: [ProcessValue<Dimension>]]

    init(id: String?, placemark: String?, location: Location, measurements: [IncidenceSelector: [ProcessValue<Dimension>]], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }
}
