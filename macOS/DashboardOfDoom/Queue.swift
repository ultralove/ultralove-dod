import Foundation

struct Queue<T> {
    private var elements: [T] = []

    init(with: [T]) {
        elements = with
    }

    mutating func enqueue(_ element: T) {
        elements.append(element)
    }

    mutating func dequeue() -> T? {
        guard elements.isEmpty == false else { return nil }
        return elements.removeFirst()
    }

    func first() -> T? {
        return elements.first
    }

    var isEmpty: Bool {
        elements.isEmpty
    }

    var count: Int {
        elements.count
    }
}

