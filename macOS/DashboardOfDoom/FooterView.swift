import SwiftUI

struct FooterView: View {
    @Environment(\.colorScheme) var colorScheme

    var sensor: Sensor?

    var body: some View {
        HStack {
            Text("Last update: \(Date.absoluteString(date: sensor?.timestamp))")
                .font(.footnote)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

struct ChartFooter: View {
    @Environment(\.colorScheme) var colorScheme

    var sensor: ProcessSensor?

    var body: some View {
        HStack {
            Text("Last update: \(Date.absoluteString(date: sensor?.timestamp))")
                .font(.footnote)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

