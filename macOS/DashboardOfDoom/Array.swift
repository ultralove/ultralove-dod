import Foundation

extension Array where Element == Measurement<Dimension> {
    // sigma: Controls the spread of the Gaussian curve. Larger values create more smoothing
    // windowSize: The size of the smoothing window. Should be odd for symmetric smoothing
    func gaussianSmoothed(sigma: Double = 1.0, windowSize: Int = 5) -> [Element] {
        guard count > windowSize else { return self }

        // Create Gaussian kernel
        let kernel = createGaussianKernel(sigma: sigma, windowSize: windowSize)
        let radius = windowSize / 2

        // Convert measurements to base unit values for calculations
        let baseValues = self.map { $0.value }

        // Apply convolution with Gaussian kernel
        var smoothedValues: [Double] = []

        for i in 0..<count {
            var sum = 0.0
            var weightSum = 0.0

            for k in -radius...radius {
                let pos = i + k
                if pos >= 0 && pos < count {
                    let weight = kernel[k + radius]
                    sum += baseValues[pos] * weight
                    weightSum += weight
                }
            }

            // Normalize by weight sum to handle edge cases
            smoothedValues.append(sum / weightSum)
        }

        // Convert back to measurements using the original unit of each value
        return zip(self, smoothedValues).map { original, smoothedValue in
            Measurement(value: smoothedValue, unit: original.unit)
        }
    }

    private func createGaussianKernel(sigma: Double, windowSize: Int) -> [Double] {
        let radius = windowSize / 2
        var kernel = [Double]()

        for x in -radius...radius {
            let exponent = -Double(x * x) / (2.0 * sigma * sigma)
            let value = exp(exponent) / (sigma * sqrt(2.0 * .pi))
            kernel.append(value)
        }

        // Normalize kernel
        let sum = kernel.reduce(0.0, +)
        return kernel.map { $0 / sum }
    }
}


