import Foundation

public class ProcessManager: Identifiable, LocationManagerDelegate {
    public let id = UUID()
    public static let shared = ProcessManager()

    private let locationManager = LocationManager()
    private var location: Location?

    private let updateInterval: TimeInterval = 60
    private var subscriptions: [ProcessSubscription] = []
    private var subscribers: [UUID: any ProcessSubscriber] = [:]

    private init() {
        self.locationManager.delegate = self
        Timer.scheduledTimer(withTimeInterval: self.updateInterval, repeats: true) { _ in
            self.updateSubscriptions()
        }
    }

    private func updateSubscriptions() {
        for subscription in self.subscriptions {
            subscription.update(timeout: self.updateInterval)
            if subscription.isPending() {
                if let delegate = self.subscribers[subscription.id], let location = self.location {
                    Task {
                        await delegate.refreshData(location: location)
                    }
                }
                subscription.reset()
            }
        }
    }

    public func refreshSubscriptions() {
        if let location = self.location {
            for delegate in self.subscribers.values {
                Task {
                    await delegate.refreshData(location: location)
                }
            }
            self.resetSubscriptions()
        }
    }

    public func refreshSubscription(subscriber: any ProcessSubscriber) {
        if let location = self.location {
            if let delegate = self.subscribers[subscriber.id] {
                Task {
                    await delegate.refreshData(location: location)
                }
            }
        }
    }

    private func resetSubscriptions() {
        for subscription in self.subscriptions {
            subscription.reset()
        }
    }

    public func resetSubscription(subscriber: any ProcessSubscriber) {
        if let delegate = self.subscribers[subscriber.id] {
            Task {
                await delegate.resetData()
            }
        }
    }


    func locationManager(didUpdateLocation location: Location) {
        self.location = location
        self.refreshSubscriptions()
    }

    func add(subscriber: any ProcessSubscriber, timeout: TimeInterval) {
        self.subscriptions.append(ProcessSubscription(id: subscriber.id, timeout: timeout * 60))
        self.subscribers[subscriber.id] = subscriber
    }

    func remove(subscriber: any ProcessSubscriber) {
        self.subscriptions.removeAll { $0.id == id }
        self.subscribers.removeValue(forKey: subscriber.id)
    }
}
