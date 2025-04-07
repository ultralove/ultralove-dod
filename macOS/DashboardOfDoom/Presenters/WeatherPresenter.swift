import CoreLocation
import MapKit
import SwiftUI

@Observable class WeatherPresenter: ProcessPresenter, ProcessSubscriberProtocol {
    private let processController = WeatherController()
    private let processTransformer = WeatherTransformer()

    override init() {
        super.init()
        let processManager = ProcessManager.shared
        processManager.add(subscriber: self, timeout: 5)  // 5 minutes
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

    @MainActor func publishData(sensor: ProcessSensor) async -> Void {
        self.sensor = sensor
        self.timestamp = sensor.timestamp

        self.measurements = self.processTransformer.measurements
        self.current = self.processTransformer.current
        self.faceplate = self.processTransformer.faceplate
        self.range = self.processTransformer.range
        self.trend = self.processTransformer.trend
    }
}
