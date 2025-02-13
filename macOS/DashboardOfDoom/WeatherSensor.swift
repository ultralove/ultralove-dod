import Foundation

class WeatherSensor : Sensor {
    var measurements: Weather

    init(id: String?, placemark: String?, location: Location, measurements: Weather, timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }
}
