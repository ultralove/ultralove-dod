import Foundation

protocol SubscriberProtocol: Identifiable where ID == UUID {
    func refreshData(location: Location) async
}

