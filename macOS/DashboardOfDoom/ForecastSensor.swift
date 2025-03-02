import Foundation

class ForecastSensor : Sensor {
    let measurements: [ForecastSelector: [ProcessValue<Dimension>]]

    init(id: String?, placemark: String?, location: Location, measurements: [ForecastSelector: [ProcessValue<Dimension>]], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }
}
