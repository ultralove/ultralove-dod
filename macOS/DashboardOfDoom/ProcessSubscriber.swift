import Foundation

public protocol ProcessSubscriber: Identifiable where ID == UUID {
    func refreshData(location: Location) async
    func resetData() async
}

