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
        }
        else {
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
        case covid
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
                                ParticleView(selector: .pm10)
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
                        case .covid:
                            VStack {
                                IncidenceView()
                                    .frame(height: 233)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "COVID-19 situation"
                            }
                        case .environment:
                            VStack {
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
                                ForEach(ParticleSelector.allCases, id: \.self) { selector in
                                    ParticleView(selector: selector)
                                        .frame(height: 233)
                                }
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
                                Image(systemName: selectedScreen == .home ? "house.fill" : "house")
                                    .foregroundColor(selectedScreen == .home ? .accentColor : .accentColor.opacity(0.5))
                            }
                            Spacer()
                            Button(action: { selectedScreen = .weather }) {
                                Image(systemName: selectedScreen == .weather ? "cloud.bolt.fill" : "cloud.sun")
                                    .foregroundColor(selectedScreen == .weather ? .accentColor : .accentColor.opacity(0.5))
                            }
                            Spacer()
                            Button(action: { selectedScreen = .covid }) {
                                Image(systemName: selectedScreen == .covid ? "facemask.fill" : "facemask")
                                    .foregroundColor(selectedScreen == .covid ? .accentColor : .accentColor.opacity(0.5))
                            }
                            Spacer()
                            Button(action: { selectedScreen = .environment }) {
                                Image(systemName: selectedScreen == .environment ? "tornado" : "ladybug")
                                    .foregroundColor(selectedScreen == .environment ? .accentColor : .accentColor.opacity(0.5))
                            }
                            Spacer()
                            Button(action: { selectedScreen = .airQuality }) {
                                Image(systemName: selectedScreen == .airQuality ? "aqi.medium" : "aqi.low")
                                    .foregroundColor(selectedScreen == .airQuality ? .accentColor : .accentColor.opacity(0.5))
                                    .fontWeight(.black) // Workaround for "aqi.medium" icon being rather thin
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
