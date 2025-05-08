import Foundation

@Observable class ProcessPresenter {
    let id = UUID()
    var sensor: ProcessSensor?
    var measurements: [ProcessSelector: [ProcessValue<Dimension>]] = [:]
    var timestamp: Date? = nil

    var current: [ProcessSelector: ProcessValue<Dimension>] = [:]
    var faceplate: [ProcessSelector: String] = [:]
    var range: [ProcessSelector: ClosedRange<Double>] = [:]
    var trend: [ProcessSelector: String] = [:]


    var label: String {
        if let customData = sensor?.customData {
            if let label = customData["label"] as? String {
                return label
            }
        }
        return "<Unknown>"
    }

    var icon: String {
        if let customData = sensor?.customData {
            if let icon = customData["icon"] as? String {
                return icon
            }
        }
        return "questionmark.circle"
    }

    var name: String {
        return sensor?.name ?? "<Unknown>"
    }

    var location: Location {
        return sensor?.location ?? Location(latitude: 0.0, longitude: 0.0)
    }

    var placemark: String {
        return sensor?.placemark ?? "<Unknown>"
    }

    func isAvailable(selector: ProcessSelector) -> Bool {
        if let measurements = self.measurements[selector] {
            if measurements.count > 0 {
                for measurement in measurements {
                    if measurement.quality != .unknown {
                        if measurement.value.value > 0.0 {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
}

