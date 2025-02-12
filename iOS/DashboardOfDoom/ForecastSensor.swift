import Foundation

class ForecastSensor : Sensor {
    let measurements: [ForecastSelector: [Forecast]]

    init(id: String?, placemark: String?, location: Location, measurements: [ForecastSelector: [Forecast]], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }
}
