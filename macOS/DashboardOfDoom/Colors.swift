import SwiftUI

extension Color {
    init(light: Color, dark: Color) {
        self.init(NSColor(name: nil, dynamicProvider: { appearance in
            return (appearance.name) == .darkAqua ? NSColor(dark) : NSColor(light)
        }))
    }
}

