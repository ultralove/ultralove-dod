import Foundation

protocol ProcessControllerProtocol {
    func refreshData(for location: Location) async throws -> ProcessSensor?
}

