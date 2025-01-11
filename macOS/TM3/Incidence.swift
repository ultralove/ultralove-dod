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
        self.init(value: value, quality: quality, timestamp: Date())
    }
}
