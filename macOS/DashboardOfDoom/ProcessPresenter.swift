import Foundation

protocol PresenterProtocol: Identifiable {
    func faceplate(selector: ProcessSelector) -> String
    func maxValue(selector: ProcessSelector) -> Double
    func minValue(selector: ProcessSelector) -> Double
}

class ProcessPresenter {
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
}

