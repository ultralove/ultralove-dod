import Foundation

struct ProcessValue<T: Dimension>: Identifiable {
    let id = UUID()
    let value: Measurement<T>
    let quality: ProcessValueQuality
    let timestamp: Date

    init(value: Measurement<T>, quality: ProcessValueQuality, timestamp: Date) {
        self.value = value
        self.quality = quality
        self.timestamp = timestamp
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

    init(value: Double, quality: ProcessValueQuality, timestamp: Date) {
        self.init(value: Measurement<T>(value: value, unit: T.baseUnit()), quality: quality, timestamp: timestamp)
    }

    init(value: Double, quality: ProcessValueQuality) {
        self.init(value: Measurement<T>(value: value, unit: T.baseUnit()), quality: quality)
    }

    init(value: Double) {
        self.init(value: Measurement<T>(value: value, unit: T.baseUnit()))
    }
}

