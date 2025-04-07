import Foundation

@Observable class CovidPresenter: ProcessPresenter, ProcessSubscriberProtocol {
    private let processController = CovidController()
    private let processTransformer = CovidTransformer()

    override init() {
        super.init()
        let processManager = ProcessManager.shared
        processManager.add(subscriber: self, timeout: 360)  // 6  hours
    }

    func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await processController.refreshData(for: location) {
                try self.processTransformer.renderData(sensor: sensor)
                await self.publishData(sensor: sensor)
            }
        }
        catch {
            trace.error("Error refreshing data: %@", error.localizedDescription)
        }
    }

    @MainActor func publishData(sensor: ProcessSensor) async {
        self.sensor = sensor
        self.timestamp = sensor.timestamp

        self.measurements = self.processTransformer.measurements
        self.current = self.processTransformer.current
        self.faceplate = self.processTransformer.faceplate
        self.range = self.processTransformer.range
        self.trend = self.processTransformer.trend

        MapPresenter.shared.updateRegion(for: self.id, with: sensor.location)
    }
}
