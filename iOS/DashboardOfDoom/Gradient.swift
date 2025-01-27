import SwiftUI

extension Gradient {

#if os(iOS)
    static let linear = LinearGradient(
        gradient: Gradient(colors: [Color.accentColor.opacity(0.67), Color.accentColor.opacity(0.0)]),
        startPoint: .top,
        endPoint: .bottom)

    static let fascists = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.2, blue: 0.1),
            Color(red: 0.3, green: 0.15, blue: 0.05)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    static let clowns = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.8, green: 0.6, blue: 0.0),
            Color(red: 0.6, green: 0.4, blue: 0.0)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
#else
    static let linear = LinearGradient(
        gradient: Gradient(colors: [Color.blue.opacity(0.66), Color.blue.opacity(0.0)]),
        startPoint: .top,
        endPoint: .bottom)

    static let fascists = LinearGradient(
        gradient: Gradient(colors: [Color.brown.opacity(1.0), Color.brown.opacity(0.33)]),
        startPoint: .top,
        endPoint: .bottom)

    static let clowns = LinearGradient(
        gradient: Gradient(colors: [Color.yellow.opacity(1.0), Color.yellow.opacity(0.33)]),
        startPoint: .top,
        endPoint: .bottom)
#endif

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
