import Foundation

protocol ProcessController {
    func refreshData(for location: Location) async throws -> ProcessSensor?
}

