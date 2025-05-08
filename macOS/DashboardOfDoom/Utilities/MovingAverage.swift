import Foundation

func movingAverage(data: [ProcessValue<Dimension>], windowSize: Int) -> [ProcessValue<Dimension>] {
    guard data.isEmpty == false else { return [] }
    guard windowSize > 0 else { return data }

    let unit = data[0].value.unit

    return data.indices.map { i in
        let start = max(0, i - windowSize + 1)
        let window = data[start ... i]
        let average = window.map { $0.value.value }.reduce(0.0, +) / Double(window.count)

        return ProcessValue(
            value: Measurement(value: average, unit: unit),
            customData: window.last?.customData,
            quality: window.last?.quality ?? .unknown,
            timestamp: window.last?.timestamp ?? Date()
        )
    }
}

func exponentialMovingAverage(data: [ProcessValue<Dimension>], alpha: Double) -> [ProcessValue<Dimension>] {
    guard data.isEmpty == false else { return [] }

    var smoothed: [ProcessValue<Dimension>] = []

    let unit = data[0].value.unit
    var previousValue = data[0].value.value

    smoothed.append(
        ProcessValue(
            value: Measurement(value: previousValue, unit: unit),
            customData: data[0].customData,
            quality: data[0].quality,
            timestamp: data[0].timestamp
        ))

    for i in 1 ..< data.count {
        let current = data[i]
        let currentValue = current.value.value

        let ema = alpha * currentValue + (1 - alpha) * previousValue
        previousValue = ema

        smoothed.append(
            ProcessValue(
                value: Measurement(value: ema, unit: unit),
                customData: current.customData,
                quality: current.quality,
                timestamp: current.timestamp
            ))
    }

    return smoothed
}

/// Applies Gaussian smoothing to the `value` field of ProcessValue elements,
/// preserving all other metadata.
func gaussianSmoothing<T: Dimension>(data: [ProcessValue<T>], windowSize: Int = 5, sigma: Double = 1.0) -> [ProcessValue<T>] {
    guard data.isEmpty == false else { return [] }
    let count = data.count
    let radius = windowSize / 2

    // Precompute Gaussian weights
    let weights: [Double] = (0 ..< windowSize).map { i in
        let x = Double(i - radius)
        return exp(-x * x / (2 * sigma * sigma))
    }

    // Smooth each ProcessValue in place
    var smoothed: [ProcessValue<T>] = []
    for i in 0 ..< count {
        var weightedSum = 0.0
        var localWeightSum = 0.0
        let unit = data[i].value.unit

        for j in -radius ... radius {
            let index = i + j
            if index >= 0 && index < count {
                let neighbor = data[index].value.converted(to: unit)
                let weight = weights[j + radius]
                weightedSum += neighbor.value * weight
                localWeightSum += weight
            }
        }

        let smoothedMeasurement = Measurement(value: weightedSum / localWeightSum, unit: unit)

        // Create new ProcessValue with smoothed value, preserving other fields
        let original = data[i]
        let smoothedProcessValue = ProcessValue(
            value: smoothedMeasurement,
            customData: original.customData,
            quality: original.quality,
            timestamp: original.timestamp
        )
        smoothed.append(smoothedProcessValue)
    }

    return smoothed
}
