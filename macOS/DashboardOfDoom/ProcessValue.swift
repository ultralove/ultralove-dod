import Foundation

struct ProcessValue<T: Dimension>: Identifiable {
    let id = UUID()
    let value: Measurement<T>
    let customData: [String: Any]?
    let quality: ProcessValueQuality
    let timestamp: Date

    init(value: Measurement<T>, customData: [String: Any]?, quality: ProcessValueQuality, timestamp: Date) {
        self.value = value
        self.customData = customData
        self.quality = quality
        self.timestamp = timestamp
    }

    init(value: Measurement<T>, quality: ProcessValueQuality, timestamp: Date) {
        self.init(value: value, customData: nil, quality: quality, timestamp: timestamp)
    }

    init(value: Measurement<T>, quality: ProcessValueQuality) {
        self.init(value: value, quality: quality, timestamp: Date.now)
    }

    init(value: Measurement<T>) {
        self.init(value: value, quality: .unknown)
    }

    init() {
        self.init(value: Measurement<T>(value: 0, unit: T.baseUnit()), quality: .unknown)
    }
}

