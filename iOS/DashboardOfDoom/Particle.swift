import Foundation

struct Particle: Identifiable {
    let id = UUID()
    let value: Measurement<UnitConcentrationMass>
    let quality: QualityCode
    let timestamp: Date

    init(value: Measurement<UnitConcentrationMass>, quality: QualityCode, timestamp: Date) {
        self.value = value
        self.quality = quality
        self.timestamp = timestamp
    }

    init(value: Measurement<UnitConcentrationMass>, quality: QualityCode) {
        self.init(value: value, quality: quality, timestamp: Date.now)
    }

    init(value: Measurement<UnitConcentrationMass>) {
        self.init(value: value, quality: .unknown)
    }

    init() {
        self.init(value: Measurement<UnitConcentrationMass>(value: 0, unit: .microgramsPerCubicMeter), quality: .unknown)
    }

    init(value: Double, quality: QualityCode, timestamp: Date) {
        self.init(value: Measurement<UnitConcentrationMass>(value: value, unit: .microgramsPerCubicMeter), quality: quality, timestamp: timestamp)
    }

    init(value: Double, quality: QualityCode) {
        self.init(value: Measurement<UnitConcentrationMass>(value: value, unit: .microgramsPerCubicMeter), quality: quality)
    }

    init(value: Double) {
        self.init(value: Measurement<UnitConcentrationMass>(value: value, unit: .microgramsPerCubicMeter))
    }
}

