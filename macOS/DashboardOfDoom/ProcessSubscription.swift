import Foundation

class ProcessSubscription: Identifiable {
    let id: UUID
    let timeout: TimeInterval
    var remaining: TimeInterval

    init(id: UUID, timeout: TimeInterval) {
        self.id = id
        self.timeout = (timeout >= 60) ? timeout : 60
        self.remaining = self.timeout
    }

    func update(timeout: TimeInterval) -> Void {
        self.remaining -= timeout
    }

    func isPending() -> Bool {
        return self.remaining <= 0
    }

    func reset() -> Void {
        self.remaining = self.timeout
    }
}
