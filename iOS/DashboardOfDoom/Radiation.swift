import Foundation

struct Radiation: Identifiable {
    let id = UUID()
    let value: Measurement<UnitRadiation>
    let quality: QualityCode
    let timestamp: Date

    init(value: Measurement<UnitRadiation>, quality: QualityCode, timestamp: Date) {
        self.value = value
        self.quality = quality
        self.timestamp = timestamp
    }

    init(value: Measurement<UnitRadiation>, quality: QualityCode) {
        self.init(value: value, quality: quality, timestamp: Date.now)
    }

    init(value: Measurement<UnitRadiation>) {
        self.init(value: value, quality: .unknown, timestamp: Date.now)
    }

    init() {
        self.init(value: Measurement<UnitRadiation>(value: 0, unit: .microsieverts), quality: .unknown)
}

    init(value: Double, quality: QualityCode, timestamp: Date) {
        self.init(value: Measurement<UnitRadiation>(value: value, unit: .microsieverts), quality: quality, timestamp: timestamp)
    }

    init(value: Double, quality: QualityCode) {
        self.init(value: Measurement<UnitRadiation>(value: value, unit: .microsieverts), quality: quality)
    }

    init(value: Double) {
        self.init(value: Measurement<UnitRadiation>(value: value, unit: .microsieverts))
    }
}



