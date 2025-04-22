import Foundation

func movingAverage(data: [ProcessValue<Dimension>], windowSize: Int) -> [ProcessValue<Dimension>] {
    guard data.isEmpty == false else { return [] }
    guard windowSize > 0 else { return data }

    let unit = data[0].value.unit

    return data.indices.map { i in
        let start = max(0, i - windowSize + 1)
        let window = data[start...i]
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

    smoothed.append(ProcessValue(
        value: Measurement(value: previousValue, unit: unit),
        customData: data[0].customData,
        quality: data[0].quality,
        timestamp: data[0].timestamp
    ))

    for i in 1..<data.count {
        let current = data[i]
        let currentValue = current.value.value

        let ema = alpha * currentValue + (1 - alpha) * previousValue
        previousValue = ema

        smoothed.append(ProcessValue(
            value: Measurement(value: ema, unit: unit),
            customData: current.customData,
            quality: current.quality,
            timestamp: current.timestamp
        ))
    }

    return smoothed
}
