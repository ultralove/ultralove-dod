import LaunchAtLogin
import SwiftUI

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct MapSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            content
                .frame(height: 667)
        }
        else {
            content
                .frame(height: 367)
        }
        #else
        content
            .frame(height: 723)
        #endif
    }
}

struct ContentPanelStyle: DisclosureGroupStyle {
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

struct ContentPanelView<Content: View>: View {
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
        .disclosureGroupStyle(ContentPanelStyle())
    }
}


struct ContentView: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(\.colorScheme) var colorScheme
    @Environment(WeatherPresenter.self) private var viewModel

    var body: some View {
        VStack {
            HStack {
                Image("dashboard-of-doom-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 34)
                    .padding(.top, 10)
                Spacer()
                HStack(alignment: .bottom) {
                    HStack(alignment: .bottom) {
                        Image(systemName: "ladybug")
                            .foregroundColor(.red)
                            .imageScale(.large)
                        Text("Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                        Text("Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")")
                    }
                    Menu {
                        Button("Settings...") {
                        }
                        .keyboardShortcut(",", modifiers: .command)
                        Divider()
                        LaunchAtLogin.Toggle()
                        Button("About...") {
                        }
                        Divider()
                        Button("Quit") {
                            NSApplication.shared.terminate(nil)
                        }
                        .keyboardShortcut("q", modifiers: .command)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                    .buttonStyle(GrowingButton())
                    .focusable(false)
                }
            }
            .padding()
            .frame(height: 34)
            ScrollView {
                VStack {
                    MapView()
                        .padding(.vertical, 5)
                        .modifier(MapSizeModifier())
                    Divider()
                    ContentPanelView(label: "Weather Forecast", icon: "cloud.sun") {
                        ForecastView()
                    }
                    Divider()
                    ContentPanelView(label: "COVID-19", icon: "facemask") {
                        CovidView()
                    }
                    Divider()
                    ContentPanelView(label: "Water", icon: "water.waves") {
                        LevelView()
                    }
                    Divider()
                    ContentPanelView(label: "Radiation", icon: "atom") {
                        RadiationView()
//                            .padding(.vertical, 5)
//                            .frame(height: 200)
                    }
                    Divider()
                    ContentPanelView(label: "Particulate Matter", icon: "aqi.medium") {
                        ParticleView()
                    }
                    Divider()
                    ContentPanelView(label: "Election Polls", icon: "popcorn") {
                        SurveyView()
                    }
                }
            }
            .padding(.bottom, 10)
        }
        .frame(width: 1024, height: 1024)
        .preferredColorScheme(.dark)
        .foregroundStyle(colorScheme == .dark ? Color.cyan : Color.black)
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}
