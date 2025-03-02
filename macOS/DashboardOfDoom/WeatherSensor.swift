import Foundation

class WeatherSensor : Sensor {
    var measurements: [WeatherSelector: ProcessValue<Dimension>] = [:]

    init(id: String?, placemark: String?, location: Location, measurements: [WeatherSelector: ProcessValue<Dimension>], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }

    init(id: String?, placemark: String?, location: Location, measurements: [WeatherSelector: ProcessValue<Dimension>], customData: [String: Any], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, customData: customData, location: location, timestamp: timestamp)
    }
}
