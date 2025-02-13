import Foundation

struct Incidence: Identifiable {
    let id = UUID()
    let value: Measurement<UnitIncidence>
    let quality: QualityCode
    let timestamp: Date

    init(value: Measurement<UnitIncidence>, quality: QualityCode, timestamp: Date) {
        self.value = value
        self.quality = quality
        self.timestamp = timestamp
    }

    init(value: Measurement<UnitIncidence>, quality: QualityCode) {
        self.init(value: value, quality: quality, timestamp: Date.now)
    }

    init(value: Measurement<UnitIncidence>) {
        self.init(value: value, quality: .unknown)
    }

    init() {
        self.init(value: Measurement<UnitIncidence>(value: 0, unit: .casesper100k), quality: .unknown)
    }

    init(value: Double, quality: QualityCode, timestamp: Date) {
        self.init(value: Measurement<UnitIncidence>(value: value, unit: .casesper100k), quality: quality, timestamp: timestamp)
    }

    init(value: Double, quality: QualityCode) {
        self.init(value: Measurement<UnitIncidence>(value: value, unit: .casesper100k), quality: quality)
    }

    init(value: Double) {
        self.init(value: Measurement<UnitIncidence>(value: value, unit: .casesper100k))
    }
}
