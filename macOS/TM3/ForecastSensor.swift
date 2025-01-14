import Foundation

class ForecastSensor : Sensor {
    let measurements: [Forecast]

    init(id: String?, placemark: String?, location: Location, measurements: [Forecast], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }
}
