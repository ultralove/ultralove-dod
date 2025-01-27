import Foundation

struct Fascism: Identifiable {
    let id = UUID()
    let value: Measurement<UnitPercentage>
    let quality: QualityCode
    let timestamp: Date

    init(value: Measurement<UnitPercentage>, quality: QualityCode, timestamp: Date) {
        self.value = value
        self.quality = quality
        self.timestamp = timestamp
    }

    init(value: Measurement<UnitPercentage>, quality: QualityCode) {
        self.init(value: value, quality: quality, timestamp: Date.now)
    }

    init(value: Measurement<UnitPercentage>) {
        self.init(value: value, quality: .unknown)
    }

    init() {
        self.init(value: Measurement<UnitPercentage>(value: 0, unit: .percent), quality: .unknown)
    }

    init(value: Double, quality: QualityCode, timestamp: Date) {
        self.init(value: Measurement<UnitPercentage>(value: value, unit: .percent), quality: quality, timestamp: timestamp)
    }

    init(value: Double, quality: QualityCode) {
        self.init(value: Measurement<UnitPercentage>(value: value, unit: .percent), quality: quality)
    }

    init(value: Double) {
        self.init(value: Measurement<UnitPercentage>(value: value, unit: .percent))
    }
}
