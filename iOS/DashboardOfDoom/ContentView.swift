import Charts
import MapKit
import SwiftUI

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

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
        }
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
        case particles
        case surveys
        case settings
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    HStack {
                        Image("dashboard-of-doom-logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 34)
                            .padding(.top, 10)
                            .padding(.leading, 5)
                        Spacer()
                    }
                    switch selectedScreen {
                        case .home:
                            VStack {
                                MapView()
                                    .padding(5)
                                    .padding(.trailing, 5)
                                    .modifier(MapSizeModifier())
                                Divider()
                                    .padding(.horizontal, 5)
                                    .padding(.trailing, 5)
                                LevelView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                                Divider()
                                    .padding(.horizontal, 5)
                                    .padding(.trailing, 5)
                                RadiationView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Home"
                            }
                        case .weather:
                            VStack {
                                ForecastView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Weather Forecast"
                            }
                        case .covid:
                            VStack {
                                CovidView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "COVID-19 Situation"
                            }
                        case .particles:
                            VStack {
                                ParticleView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Particulate Matter"
                            }
                        case .surveys:
                            VStack {
                                SurveyView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Election Polls"
                            }
                        case .settings:
                            VStack {
                                SettingsView()
                            }
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
                            Button(action: { selectedScreen = .particles }) {
                                Image(systemName: selectedScreen == .particles ? "aqi.medium" : "aqi.low")
                                    .foregroundColor(selectedScreen == .particles ? .accentColor : .accentColor.opacity(0.5))
                                    .fontWeight(.black)  // Workaround for "aqi.medium" icon being rather thin
                            }
                            Spacer()
                            Button(action: { selectedScreen = .surveys }) {
                                Image(systemName: selectedScreen == .surveys ? "popcorn.fill" : "popcorn")
                                    .foregroundColor(selectedScreen == .surveys ? .accentColor : .accentColor.opacity(0.5))
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
            //            .refreshable {
            //                SubscriptionManager.shared.refresh()
            //            }
        }
    }
}
