import SwiftUI

struct SensorPanelStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            Button {
                configuration.isExpanded.toggle()
            } label: {
                HStack {
                    configuration.label
                    Spacer()
                    Image(systemName: configuration.isExpanded ? "arrowtriangle.down" : "arrowtriangle.forward")
                        .fontWeight(.light)
                }
                .padding(.vertical, 8)
                .padding(.trailing)
                .frame(height: 23)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if configuration.isExpanded {
                configuration.content
                    .padding(.leading)
            }
        }
        .focusable(false)
    }
}

struct SensorPanel<Content: View>: View {
    let label: String
    let icon: String
    @State private var isExpanded: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                content()
            },
            label: {
                HStack {
                    Image(systemName: self.icon)
                        .imageScale(.large)
                        .frame(width: 23)
                    Text(self.label)
                }
                .padding()
                .fontWeight(.light)
            }
        )
        .disclosureGroupStyle(SensorPanelStyle())
    }
}

struct SensorPanel2<Content: View>: View {
    let label: String
    let icon: String
    let placemark: String?
    @State private var isExpanded: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                content()
            },
            label: {
                VStack {
                    HStack {
                        Image(systemName: self.icon)
                            .imageScale(.large)
                            .frame(width: 23)
                        Text(self.label)
                    }
                    .padding()
                    .fontWeight(.light)
                    HStack {
                        Image(systemName: "globe")
                        Text(String(format: "%@", self.placemark ?? "<Unknown>"))
                    }
                    .font(.footnote)
                }
            }
        )
        .disclosureGroupStyle(SensorPanelStyle())
    }
}

