import SwiftUI

struct FooterView: View {
    var sensor: Sensor?

    var body: some View {
        HStack {
            Text("Last update: \(Date.absoluteString(date: sensor?.timestamp))")
                .font(.footnote)
            Spacer()
        }
    }
}

