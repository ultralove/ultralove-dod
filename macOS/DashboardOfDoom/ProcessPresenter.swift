import Foundation

@Observable class ProcessPresenter {
    let id = UUID()
    var sensor: ProcessSensor?
    var measurements: [ProcessSelector: [ProcessValue<Dimension>]] = [:]
    var timestamp: Date? = nil

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

    var location: Location? {
        return sensor?.location
    }

    var placemark: String {
        return sensor?.placemark ?? "<Unknown>"
    }

    func isAvailable(selector: ProcessSelector) -> Bool {
        guard let measurements = self.measurements[selector] else {
            return false
        }
        return measurements.count > 0
    }
}

