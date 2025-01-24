import SwiftUI

extension Gradient {
    static let linearBlue = LinearGradient(
        gradient: Gradient(colors: [Color.blue.opacity(0.66), Color.blue.opacity(0.0)]),
        startPoint: .top,
        endPoint: .bottom)

    static let linearBlack = LinearGradient(
        gradient: Gradient(colors: [Color.black.opacity(0.66), Color.black.opacity(0.0)]),
        startPoint: .top,
        endPoint: .bottom)

    static let fascist = LinearGradient(
        gradient: Gradient(colors: [Color.brown.opacity(1.0), Color.brown.opacity(0.33)]),
        startPoint: .top,
        endPoint: .bottom)

    static let rainbow = LinearGradient(
        stops: [
            Gradient.Stop(color: .blue, location: 0),
            Gradient.Stop(color: .blue.opacity(0.5), location: 0.125),
            Gradient.Stop(color: .yellow, location: 0.25),
            Gradient.Stop(color: .orange, location: 0.5),
            Gradient.Stop(color: .red, location: 0.75),
            Gradient.Stop(color: .purple, location: 1.0)
        ],
        startPoint: .bottom, endPoint: .top)
}
