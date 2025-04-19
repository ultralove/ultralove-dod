import Foundation

protocol ProcessSubscriber: Identifiable where ID == UUID {
    func refreshData(location: Location) async
}

