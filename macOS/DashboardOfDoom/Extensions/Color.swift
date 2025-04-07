import SwiftUI

#if os(macOS)
extension Color {
    init(light: Color, dark: Color) {
        self.init(NSColor(name: nil, dynamicProvider: { appearance in
            if let appearance = NSApp.appearance, appearance.name == .darkAqua {
                return NSColor(dark)
            } else {
                return NSColor(light)
            }
        }))
    }

    static let blendedBlue = Color(red: 0.33, green: 0.67, blue: 1.0)
}
#endif

extension Color {
    #if os(macOS)
    static let location: Color = Color(light: Color.blue, dark: Color.cyan)
    static let userLocation: Color = Color(light: Color.white, dark: Color.orange)
    static let faceplate = Color(light: Color.blendedBlue, dark: Color.cyan)
    static let chart = Color(light: Color.blendedBlue, dark: Color.cyan)
    static let spaeti = Color(light: Color.blendedBlue, dark: Color.cyan.opacity(0.5))
    static let treshold = Color(light: Color.black.opacity(0.33), dark: Color.white.opacity(0.33))
    #else
    static let location: Color = .accentColor
    static let userLocation: Color = .accentColor
    static let faceplate = Self.accentColor
    static let chart = Self.accentColor
    static let spaeti = Self.accentColor
    #endif

    static let brandPrimary = Color(hex: "#FF5733") // Using hex code

    // Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
