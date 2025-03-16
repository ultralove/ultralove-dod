import Foundation

@Observable class CovidViewModel: ProcessPresenter, ProcessSubscriberProtocol {
    private let covidController = CovidController()
    private let covidRenderer = CovidRenderer()

    var current: [ProcessSelector: ProcessValue<Dimension>] = [:]
    var faceplate: [ProcessSelector: String] = [:]
    var range: [ProcessSelector: ClosedRange<Double>] = [:]
    var trend: [ProcessSelector: String] = [:]

    override init() {
        super.init()
        let subscriptionManager = ProcessManager.shared
        subscriptionManager.addSubscription(delegate: self, timeout: 360)  // 6  hours
    }

    func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await covidController.refreshData(for: location) {
                try self.covidRenderer.renderData(sensor: sensor)
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
        self.measurements = self.covidRenderer.measurements
        self.current = self.covidRenderer.current
        self.faceplate = self.covidRenderer.faceplate
        self.range = self.covidRenderer.range
        self.trend = self.covidRenderer.trend

        MapViewModel.shared.updateRegion(for: self.id, with: sensor.location)
    }
}
