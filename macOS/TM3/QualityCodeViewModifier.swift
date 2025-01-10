import SwiftUI

struct QualityCodeViewModifier: ViewModifier {
    var qualityCode: QualityCode

    var backgroundColor: Color {
        switch qualityCode {
            case .good:
                return .green
            case .uncertain:
                return .orange
            case .bad:
                return .red
            default:
                return .gray
        }
    }

    var foregroundColor: Color {
        switch qualityCode {
            case .bad:
                return .white
            default:
                return .black
        }
    }

    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: 13)
                .fill(backgroundColor)
                .opacity(0.5))
            .foregroundStyle(foregroundColor)
    }
}


