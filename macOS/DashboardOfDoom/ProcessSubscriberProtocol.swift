import Foundation

protocol ProcessSubscriberProtocol: Identifiable where ID == UUID {
    func refreshData(location: Location) async
}



