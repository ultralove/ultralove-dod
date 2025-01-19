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

    init() {
        self.init(value: Measurement<UnitPercentage>(value: 0, unit: .percent), quality: .unknown)
    }
}
