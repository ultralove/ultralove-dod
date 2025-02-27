import SwiftUI

struct HeaderView: View {
    var label: String
    var sensor: Sensor?

    var body: some View {
        VStack {
            #if os(macOS)
            HStack(alignment: .bottom) {
                if let id = sensor?.id {
                    Text(String(format: "%@ %@:", label, id))
                        .font(.headline)
                }
                else {
                    Text(String(format: "%@:", label))
                        .font(.headline)
                }
                Spacer()
                HStack {
                    Image(systemName: "globe")
                    Text(String(format: "%@", sensor?.placemark ?? "<Unknown>"))
                }
                .font(.footnote)
            }
            #else
            VStack {
                HStack {
                    if let id = sensor?.id {
                        Text(String(format: "%@ %@:", label, id))
                            .font(.headline)
                    }
                    else {
                        Text(String(format: "%@:", label))
                            .font(.headline)
                    }
                    Spacer()
                }
                HStack {
                    Image(systemName: "globe")
                    Text(String(format: "%@", sensor?.placemark ?? "<Unknown>"))
                    Spacer()
                }
                .font(.footnote)
            }
            #endif
        }
    }
}
