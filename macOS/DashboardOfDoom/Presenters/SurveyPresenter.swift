import Foundation
import SwiftUI

@Observable class SurveyPresenter: ProcessPresenter, ProcessSubscriber {
    private let controller = SurveyController()
    private let transformer = SurveyTransformer()

    override init() {
        super.init()
        let processManager = ProcessManager.shared
        processManager.add(subscriber: self, timeout: 30)  // 30 minutes
    }

    func gradient(selector: ProcessSelector) -> LinearGradient {
        switch selector {
            case .survey(.fascists):
                return Gradient.fascists
            case .survey(.afd):
                return Gradient.fascists
            case .survey(.bsw):
                return Gradient.fascists
            case .survey(.clowns):
                return Gradient.clowns
            case .survey(.fdp):
                return Gradient.clowns
            case .survey(.cducsu):
                return Gradient.fascists
            case .survey(.cdu):
                return Gradient.fascists
            case .survey(.csu):
                return Gradient.fascists
            case .survey(.spd):
                return Gradient.spd
            case .survey(.gruene):
                return Gradient.gruene
            case .survey(.linke):
                return Gradient.linke
            case .survey(.sonstige):
                return Gradient.sonstige
            default:
                return Gradient.linear
        }
    }

    func refreshData(location: Location) async -> Void {
        if UserDefaults.standard.bool(forKey: "enableElectionPolls") == true {
        do {
            if let sensor = try await controller.refreshData(for: location) {
                try self.transformer.renderData(sensor: sensor)
                await self.publishData(sensor: sensor)
            }
        }
        catch {
            trace.error("Error refreshing data: %@", error.localizedDescription)
        }
    }
    }

    func resetData() async {
        await MapPresenter.shared.updateRegion(remove: self.id)
    }

    @MainActor func publishData(sensor: ProcessSensor) async -> Void {
        self.sensor = sensor
        self.timestamp = sensor.timestamp

        self.measurements = self.transformer.measurements
        self.current = self.transformer.current
        self.faceplate = self.transformer.faceplate
        self.range = self.transformer.range
        self.trend = self.transformer.trend

        if UserDefaults.standard.integer(forKey: "electionPollScope") == 0 {
            if UserDefaults.standard.bool(forKey: "showFederalElectionPolls") == true {
        MapPresenter.shared.updateRegion(for: self.id, with: sensor.location)
    }
            else {
                MapPresenter.shared.updateRegion(remove: self.id)
            }
        }
        else {
            MapPresenter.shared.updateRegion(for: self.id, with: sensor.location)
        }
    }
}
