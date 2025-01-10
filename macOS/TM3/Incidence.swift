import Foundation

struct Incidence: Identifiable {
    let id = UUID()
    let value: Double
    let quality: QualityCode
    let timestamp: Date

    init(value: Double, quality: QualityCode, timestamp: Date) {
        self.value = value
        self.quality = quality
        self.timestamp = timestamp
    }

    init(value: Double, quality: QualityCode) {
        self.init(value: value, quality: quality, timestamp: Date())
    }

    init() {
        self.init(value: 0, quality: .unknown)
    }
}
