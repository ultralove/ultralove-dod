import Foundation

class ParticleSensor : Sensor {
    let measurements: [ParticleSelector: [Particle]]

    init(id: String?, placemark: String?, location: Location, measurements: [ParticleSelector: [Particle]], timestamp: Date?) {
        self.measurements = measurements
        super.init(id: id, placemark: placemark, location: location, timestamp: timestamp)
    }
}
