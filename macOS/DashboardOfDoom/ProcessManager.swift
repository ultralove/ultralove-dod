import Foundation

protocol ProcessControllerProtocol {
    func refreshData(for location: Location) async throws -> ProcessSensor?
}

protocol ProcessSubscriberProtocol: Identifiable where ID == UUID {
    func refreshData(location: Location) async
}

class ProcessManager: LocationManagerDelegate {
    static let shared = ProcessManager()

    private let locationManager = LocationManager()
    private var location: Location?

    private let updateInterval: TimeInterval = 60
    private var subscriptions: [ProcessSubscription] = []
    private var delegates: [UUID: any ProcessSubscriberProtocol] = [:]

    private init() {
        self.locationManager.delegate = self
        Timer.scheduledTimer(withTimeInterval: self.updateInterval, repeats: true) { _ in
            self.refreshSubscriptions()
        }
    }

    private func refreshSubscriptions() {
        for subscription in self.subscriptions {
            subscription.update(timeout: self.updateInterval)
            if subscription.isPending() {
                if let delegate = self.delegates[subscription.id], let location = self.location {
                    Task {
                        await delegate.refreshData(location: location)
                    }
                }
                subscription.reset()
            }
        }
    }

    private func resetSubscriptions() {
        for subscription in self.subscriptions {
            subscription.reset()
        }
    }

    func locationManager(didUpdateLocation location: Location) {
        self.location = location
        self.refresh()
    }

    func refresh() {
        if let location = self.location {
        for delegate in self.delegates.values {
                Task {
            await delegate.refreshData(location: location)
        }
            }
            self.resetSubscriptions()
        }
    }


    func addSubscription(delegate: any ProcessSubscriberProtocol, timeout: TimeInterval) {
        self.subscriptions.append(ProcessSubscription(id: delegate.id, timeout: timeout * 60))
        self.delegates[delegate.id] = delegate
    }

    func removeSubscription(id: UUID) {
        self.subscriptions.removeAll { $0.id == id }
        self.delegates.removeValue(forKey: id)
    }
}
