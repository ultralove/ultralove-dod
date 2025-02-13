import SwiftUI

extension View {
    func qualityCode(qualityCode: QualityCode) -> some View {
        self.modifier(QualityCodeViewModifier(qualityCode: qualityCode))
    }
}



