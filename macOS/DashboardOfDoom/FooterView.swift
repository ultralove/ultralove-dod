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

