import Foundation

class SurveySensor : Sensor {
    let measurements: [SurveySelector:[Survey]]

    init(id: String?, placemark: String?, location: Location, measurements: [SurveySelector:[Survey]], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }
}

