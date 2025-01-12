import Foundation

struct Level: Identifiable {
    let id = UUID()
    let value: Measurement<UnitLength>
    let quality: QualityCode
    let timestamp: Date

    init(value: Measurement<UnitLength>, quality: QualityCode, timestamp: Date) {
        self.value = value
        self.quality = quality
        self.timestamp = timestamp
    }

    init(value: Measurement<UnitLength>, quality: QualityCode) {
        self.init(value: value, quality: quality, timestamp: Date.now)
    }

    init() {
        self.init(value: Measurement<UnitLength>(value: 0, unit: .meters), quality: .unknown)
    }
}

