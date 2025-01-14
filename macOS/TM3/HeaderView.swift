import SwiftUI

struct HeaderView: View {
    var label: String
    var sensor: Sensor?

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(String(format: "%@ %@:", label, sensor?.id ?? "<Unknown>"))
                Spacer()
                HStack {
                    Image(systemName: "globe")
                    Text(String(format: "%@", sensor?.placemark ?? "<Unknown>"))
//                        .foregroundColor(.blue)
//                        .underline()
                        .onTapGesture {
                        }
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                }
                .font(.footnote)
            }
        }
    }
}

