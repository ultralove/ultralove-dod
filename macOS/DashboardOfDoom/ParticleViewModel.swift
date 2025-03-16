import SwiftUI

@Observable class ParticleViewModel: ProcessPresenter, ProcessSubscriberProtocol {
    private let particleController = ParticleController()
    private let particleRenderer = ParticleRenderer()

    var current: [ProcessSelector: ProcessValue<Dimension>] = [:]
    var faceplate: [ProcessSelector: String] = [:]
    var range: [ProcessSelector: ClosedRange<Double>] = [:]
    var trend: [ProcessSelector: String] = [:]

    override init() {
        super.init()
        let subscriptionManager = ProcessManager.shared
        subscriptionManager.addSubscription(delegate: self, timeout: 30)  // 30 minutes
    }

    func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await particleController.refreshData(for: location) {
                try self.particleRenderer.renderData(sensor: sensor)
                await self.publishData(sensor: sensor)
            }
        }
        catch {
            trace.error("Error refreshing data: %@", error.localizedDescription)
        }
    }

    @MainActor func publishData(sensor: ProcessSensor) async -> Void {
        self.sensor = sensor
        self.timestamp = sensor.timestamp
        self.measurements = self.particleRenderer.measurements
        self.current = self.particleRenderer.current
        self.faceplate = self.particleRenderer.faceplate
        self.range = self.particleRenderer.range
        self.trend = self.particleRenderer.trend

        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }
}
