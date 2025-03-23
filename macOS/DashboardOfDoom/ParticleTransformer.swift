import Foundation

class ParticleTransformer: ProcessTransformer {
    override func renderFaceplate(current: [ProcessSelector: ProcessValue<Dimension>]) -> [ProcessSelector: String] {
        var faceplate: [ProcessSelector: String] = [:]
        for (selector, current) in self.current {
            switch selector {
                case .particle(.pm10):
                    faceplate[selector] = String(
                        format:
                            "\(MathematicalSymbols.mathematicalBoldCapitalRho.rawValue)\(MathematicalSymbols.mathematicalBoldCapitalMu.rawValue)\u{2081}\u{2080}: %.0f%@",
                        current.value.value, current.value.unit.symbol)
                case .particle(.pm25):
                    faceplate[selector] = String(
                        format:
                            "\(MathematicalSymbols.mathematicalBoldCapitalRho.rawValue)\(MathematicalSymbols.mathematicalBoldCapitalMu.rawValue)\u{2082}\u{2085}: %.0f%@",
                        current.value.value, current.value.unit.symbol)
                case .particle(.o3):
                    faceplate[selector] = String(
                        format: "\(MathematicalSymbols.mathematicalBoldCapitalOmicron.rawValue)\u{2083}: %.0f%@", current.value.value,
                        current.value.unit.symbol)
                case .particle(.no2):
                    faceplate[selector] = String(
                        format:
                            "\(MathematicalSymbols.mathematicalBoldCapitalNu.rawValue)\(MathematicalSymbols.mathematicalBoldCapitalOmicron.rawValue)\u{2082}: %.0f%@",
                        current.value.value, current.value.unit.symbol)
                default:
                    faceplate[selector] = String(
                        format: "\(MathematicalSymbols.mathematicalBoldCapitalMu.rawValue): %.0f%@", current.value.value,
                        current.value.unit.symbol)
            }
        }
        return faceplate
    }
}
