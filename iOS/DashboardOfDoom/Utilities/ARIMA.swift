// ARIMA (AutoRegressive Integrated Moving Average)

import Foundation

// MARK: - Data Structures

/// Represents the interval between time series points
enum TimeSeriesInterval {
    case quarterHourly
    case hourly
    case daily
    case custom(TimeInterval)

    var interval: TimeInterval {
        switch self {
            case .quarterHourly: return 15 * 60  // 15 minutes
            case .hourly: return 3600  // 1 hour
            case .daily: return 24 * 3600  // 24 hours
            case .custom(let interval): return interval
        }
    }
}

/// Represents a single time series data point
struct TimeSeriesPoint {
    let timestamp: Date
    let value: Double
}

/// ARIMA model parameters
struct ARIMAParameters {
    let p: Int  // Auto-regression order
    let d: Int  // Difference order
    let q: Int  // Moving average order

    init(p: Int = 1, d: Int = 1, q: Int = 1) {
        self.p = max(0, p)
        self.d = max(0, d)
        self.q = max(0, q)
    }
}

/// ARIMA prediction result
struct ARIMAPrediction {
    let forecasts: [TimeSeriesPoint]
    let confidenceIntervals: [(lower: Double, upper: Double)]
}

// MARK: - ARIMA Framework

class ARIMAPredictor {
    private let parameters: ARIMAParameters
    private var timeSeriesData: [TimeSeriesPoint]
    private let interval: TimeSeriesInterval

    init(parameters: ARIMAParameters = ARIMAParameters(), interval: TimeSeriesInterval) {
        self.parameters = parameters
        self.interval = interval
        self.timeSeriesData = []
    }

    /// Add new time series data points
    func addData(_ points: [TimeSeriesPoint]) throws {
        // Validate time intervals between points
        if let invalidInterval = validateIntervals(points) {
            throw ARIMAError.invalidTimeInterval(expected: interval.interval, found: invalidInterval)
        }

        timeSeriesData.append(contentsOf: points)
        timeSeriesData.sort { $0.timestamp < $1.timestamp }
    }

    /// Validate that all points conform to the specified interval
    private func validateIntervals(_ points: [TimeSeriesPoint]) -> TimeInterval? {
        guard !points.isEmpty else { return nil }

        let sortedPoints = points.sorted { $0.timestamp < $1.timestamp }
        let expectedInterval = interval.interval
        let tolerance = expectedInterval * 0.01  // 1% tolerance

        for i in 0 ..< (sortedPoints.count - 1) {
            let actualInterval = sortedPoints[i + 1].timestamp.timeIntervalSince(sortedPoints[i].timestamp)
            if abs(actualInterval - expectedInterval) > tolerance { return actualInterval }
        }

        // Also validate against existing data if present
        if let lastExisting = timeSeriesData.last, let firstNew = sortedPoints.first {
            let actualInterval = firstNew.timestamp.timeIntervalSince(lastExisting.timestamp)
            if abs(actualInterval - expectedInterval) > tolerance { return actualInterval }
        }

        return nil
    }

    /// Clear all existing data
    func clearData() { timeSeriesData.removeAll() }

    /// Generate predictions for a specified duration
    func forecast(duration: TimeInterval, confidenceLevel: Double = 0.95) throws -> ARIMAPrediction {
        guard !timeSeriesData.isEmpty else { throw ARIMAError.insufficientData }

        // Extract values for processing
        let values = timeSeriesData.map { $0.value }

        // Perform differencing
        let differencedData = difference(values: values, order: parameters.d)

        // Estimate AR and MA coefficients
        let (arCoefficients, maCoefficients) = try estimateCoefficients(data: differencedData)

        // Generate forecasts
        let forecasts = try generateForecasts(
            differencedData: differencedData, arCoefficients: arCoefficients, maCoefficients: maCoefficients, duration: duration)

        // Calculate confidence intervals
        let intervals = calculateConfidenceIntervals(forecasts: forecasts, confidenceLevel: confidenceLevel)

        // Convert forecasts to TimeSeriesPoints
        let lastTimestamp = timeSeriesData.last!.timestamp
        let forecastPoints = forecasts.enumerated().map { (index, value) in
            TimeSeriesPoint(timestamp: lastTimestamp.addingTimeInterval(Double(index + 1) * duration / Double(forecasts.count)), value: value)
        }

        return ARIMAPrediction(forecasts: forecastPoints, confidenceIntervals: intervals)
    }

    // MARK: - Private Methods

    private func difference(values: [Double], order: Int) -> [Double] {
        var result = values
        for _ in 0 ..< order { result = zip(result, result.dropFirst()).map { $1 - $0 } }
        return result
    }

    private func estimateCoefficients(data: [Double]) throws -> ([Double], [Double]) {
        guard data.count >= parameters.p + parameters.q else { throw ARIMAError.insufficientData }

        // Implement Yule-Walker equations for AR coefficients
        let arCoefficients = try estimateARCoefficients(data: data)

        // Implement innovation algorithm for MA coefficients
        let maCoefficients = try estimateMACoefficients(data: data, arCoefficients: arCoefficients)

        return (arCoefficients, maCoefficients)
    }

    private func estimateARCoefficients(data: [Double]) throws -> [Double] {
        var coefficients: [Double] = []

        // Implementation of Yule-Walker equations
        let n = data.count
        var autoCorr = [Double](repeating: 0.0, count: parameters.p + 1)

        // Calculate autocorrelation
        for lag in 0 ... parameters.p {
            var sum = 0.0
            for t in lag ..< n { sum += data[t] * data[t - lag] }
            autoCorr[lag] = sum / Double(n - lag)
        }

        // Solve Yule-Walker equations using Levinson-Durbin recursion
        var phi = [[Double]](repeating: [Double](repeating: 0.0, count: parameters.p + 1), count: parameters.p + 1)
        var v = [Double](repeating: 0.0, count: parameters.p + 1)
        v[0] = autoCorr[0]

        for k in 1 ... parameters.p {
            var sum = 0.0
            for j in 1 ..< k { sum += phi[k - 1][j] * autoCorr[k - j] }
            phi[k][k] = (autoCorr[k] - sum) / v[k - 1]

            for j in 1 ..< k { phi[k][j] = phi[k - 1][j] - phi[k][k] * phi[k - 1][k - j] }

            v[k] = v[k - 1] * (1.0 - phi[k][k] * phi[k][k])
        }

        coefficients = Array(phi[parameters.p][1 ... parameters.p])
        return coefficients
    }

    private func estimateMACoefficients(data: [Double], arCoefficients: [Double]) throws -> [Double] {
        // Simplified MA coefficient estimation using innovation algorithm
        var coefficients = [Double](repeating: 0.0, count: parameters.q)

        // Remove AR component from the data
        var residuals = data
        for t in arCoefficients.count ..< data.count {
            var arComponent = 0.0
            for (j, coef) in arCoefficients.enumerated() { arComponent += coef * data[t - j - 1] }
            residuals[t] -= arComponent
        }

        // Estimate MA coefficients using correlation of residuals
        for i in 0 ..< parameters.q {
            var sum = 0.0
            var count = 0
            for t in (i + 1) ..< residuals.count {
                sum += residuals[t] * residuals[t - i - 1]
                count += 1
            }
            coefficients[i] = sum / Double(count) / variance(of: residuals)
        }

        return coefficients
    }

    private func generateForecasts(
        differencedData: [Double], arCoefficients: [Double], maCoefficients: [Double], duration: TimeInterval
    ) throws -> [Double] {
        let forecastPoints = Int(ceil(duration / averageTimeDelta()))
        var forecasts = [Double](repeating: 0.0, count: forecastPoints)

        // Generate forecasts using both AR and MA components
        for t in 0 ..< forecastPoints {
            var forecast = 0.0

            // Add AR component
            for (j, coef) in arCoefficients.enumerated() {
                let index = differencedData.count - j - 1 + t
                let value = index < differencedData.count ? differencedData[index] : forecasts[index - differencedData.count]
                forecast += coef * value
            }

            // Add MA component (only using known errors)
            for (j, coef) in maCoefficients.enumerated() {
                if t - j - 1 >= 0 { forecast += coef * (forecasts[t - j - 1] - differencedData[differencedData.count - j - 1]) }
            }

            forecasts[t] = forecast
        }

        // Reverse differencing
        return undifference(forecasts: forecasts, originalData: timeSeriesData.map { $0.value })
    }

    private func undifference(forecasts: [Double], originalData: [Double]) -> [Double] {
        var result = forecasts
        for _ in 0 ..< parameters.d {
            let lastOriginal = originalData.last!
            result = result.reduce(into: []) { (acc, value) in
                let lastValue = acc.isEmpty ? lastOriginal : acc.last!
                acc.append(lastValue + value)
            }
        }
        return result
    }

    private func calculateConfidenceIntervals(forecasts: [Double], confidenceLevel: Double) -> [(lower: Double, upper: Double)] {
        let standardError = calculateStandardError()
        let zScore = calculateZScore(for: confidenceLevel)
        let margin = standardError * zScore

        return forecasts.map { forecast in (lower: forecast - margin, upper: forecast + margin) }
    }

    private func calculateStandardError() -> Double {
        let values = timeSeriesData.map { $0.value }
        return sqrt(variance(of: values))
    }

    private func variance(of values: [Double]) -> Double {
        let mean = values.reduce(0.0, +) / Double(values.count)
        let squaredDiffs = values.map { pow($0 - mean, 2) }
        return squaredDiffs.reduce(0.0, +) / Double(values.count - 1)
    }

    private func calculateZScore(for confidenceLevel: Double) -> Double {
        // Approximate z-score for common confidence levels
        switch confidenceLevel { case 0.99: return 2.576 case 0.95: return 1.96 case 0.90: return 1.645 default: return 1.96  // Default to 95% confidence level
        }
    }

    private func averageTimeDelta() -> TimeInterval { return interval.interval }
}

// MARK: - Error Handling

enum ARIMAError: Error {
    case insufficientData
    case invalidParameters
    case convergenceFailure
    case invalidTimeInterval(expected: TimeInterval, found: TimeInterval)
}

// MARK: - Usage Example

extension ARIMAPredictor {
    static func example() {
        // Create sample data
        let now = Date()
        let sampleData = (0 ..< 100).map { i in
            TimeSeriesPoint(timestamp: now.addingTimeInterval(Double(i) * 3600), value: sin(Double(i) * 0.1) * 10 + Double.random(in: -1 ... 1))
        }

        // Initialize predictor with custom parameters and hourly interval
        let predictor = ARIMAPredictor(parameters: ARIMAParameters(p: 2, d: 1, q: 1), interval: .hourly)

        do {
            // Add data
            try predictor.addData(sampleData)
            // Generate 24-hour forecast
            let forecast = try predictor.forecast(duration: 24 * 3600)

            // Print results
            print("Forecast points:")
            for (point, interval) in zip(forecast.forecasts, forecast.confidenceIntervals) {
                print("Time: \(point.timestamp), Value: \(point.value), CI: (\(interval.lower), \(interval.upper))")
            }
        }
        catch { print("Forecasting error: \(error)") }
    }
}
