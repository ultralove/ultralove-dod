import Charts
import MapKit
import SwiftUI

//struct MapSizeModifier: ViewModifier {
//    @Environment(\.horizontalSizeClass) var sizeClass
//
//    func body(content: Content) -> some View {
//        content.frame(height: sizeClassBasedHeight)
//    }
//
//    private var sizeClassBasedHeight: CGFloat {
//        switch sizeClass {
//            case .compact:
//                return 300
//            case .regular:
//                return 500
//            default:
//                return 400
//        }
//    }
//}

struct MapSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            content
                .frame(height: 667)
        } else {
            content
                .frame(height: 367)
        }
#else
        content
            .frame(height: 500)
#endif
    }
}


struct ContentView: View {
    @State private var selectedScreen = Screen.home
    @State private var navigationVisible = Visibility.hidden
    @State private var navigationTitle = ""

    enum Screen {
        case home
        case weather
        case environment
        case airQuality
        case settings
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    switch selectedScreen {
                    case .home:
                        VStack {
                            MapView()
                                .modifier(MapSizeModifier())
                            IncidenceView()
                                .frame(height: 233)
                            LevelView()
                                .frame(height: 233)
                            RadiationView()
                                .frame(height: 233)
                        }
                        .onAppear {
                            navigationVisible = .visible
                            navigationTitle = "Home"
                        }
                    case .weather:
                        VStack {
                            ForecastView(header: "Temperature (actual)", selector: .actual)
                                .frame(height: 233)
                            ForecastView(header: "Temperature (feels like)", selector: .apparent)
                                .frame(height: 233)
                            ForecastView(header: "Dew point", selector: .dewPoint)
                                .frame(height: 233)
                            ForecastView(header: "Humidity", selector: .humidity)
                                .frame(height: 233)
                            ForecastView(header: "Precipitation chance", selector: .precipitationChance)
                                .frame(height: 233)
                            ForecastView(header: "Precipitation amount", selector: .precipitationAmount)
                                .frame(height: 233)
                            ForecastView(header: "Pressure", selector: .pressure)
                                .frame(height: 233)
                            ForecastView(header: "Visibility", selector: .visibility)
                                .frame(height: 233)
                        }
                        .onAppear {
                            navigationVisible = .visible
                            navigationTitle = "Weather forecast"
                        }

                    case .environment:
                        VStack {
                            IncidenceView()
                                .frame(height: 233)
                            LevelView()
                                .frame(height: 233)
                            RadiationView()
                                .frame(height: 233)
                        }
                        .onAppear {
                            navigationVisible = .visible
                            navigationTitle = "Environmental data"
                        }
                    case .airQuality:
                        VStack {
                            ParticleView(header: "PM\u{2081}\u{2080} at ", selector: .pm10)
                                .frame(height: 233)
                            ParticleView(header: "PM\u{2082}\u{2085} at ", selector: .pm25)
                                .frame(height: 233)
                            ParticleView(header: "NO\u{2082} at ", selector: .no2)
                                .frame(height: 233)
                        }
                        .onAppear {
                            navigationVisible = .visible
                            navigationTitle = "Particulate matter"
                        }
                    case .settings:
                        SettingsView()
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Settings"
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text(navigationTitle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.headline)
                            Spacer()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(action: { selectedScreen = .home }) {
                                Image(systemName: selectedScreen == .home ? "map.fill" : "map")
                                    .foregroundColor(selectedScreen == .home ? .accentColor : .accentColor.opacity(0.5))
                            }
                            Spacer()
                            Button(action: { selectedScreen = .weather }) {
                                Image(systemName: selectedScreen == .weather ? "cloud.bolt.fill" : "cloud.bolt")
                                    .foregroundColor(selectedScreen == .weather ? .accentColor : .accentColor.opacity(0.5))
                            }
                            Spacer()
                            Button(action: { selectedScreen = .environment }) {
                                Image(systemName: selectedScreen == .environment ? "brain.head.profile.fill" : "brain.head.profile")
                                    .foregroundColor(selectedScreen == .environment ? .accentColor : .accentColor.opacity(0.5))
                            }
                            Spacer()
                            Button(action: { selectedScreen = .airQuality }) {
                                Image(systemName: selectedScreen == .airQuality ? "flame.fill" : "flame")
                                    .foregroundColor(selectedScreen == .airQuality ? .accentColor : .accentColor.opacity(0.5))
                            }
                            Spacer()
                            Button(action: { selectedScreen = .settings }) {
                                Image(systemName: selectedScreen == .settings ? "gearshape.fill" : "gearshape")
                                    .foregroundColor(selectedScreen == .settings ? .accentColor : .accentColor.opacity(0.5))
                            }
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.visible, for: .bottomBar)
            .toolbarBackground(
                Color(
                    uiColor: UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ? .black : .white
                    }), for: .bottomBar
            )
            .refreshable {
                SubscriptionManager.shared.refresh()
            }
        }
    }
}

