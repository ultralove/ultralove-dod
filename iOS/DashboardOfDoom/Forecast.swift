import Foundation

struct Forecast: Identifiable {
   let id = UUID()
    let value: Measurement<Dimension>
    let quality: QualityCode
    let timestamp: Date
}
