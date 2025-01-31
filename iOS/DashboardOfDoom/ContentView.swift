import Charts
import MapKit
import SwiftUI

struct ContentView: View {
    @State private var selectedScreen = Screen.home
    @State private var navigationVisible = Visibility.hidden
    @State private var navigationTitle = ""

    enum Screen {
        case home
        case weather
        case environment
        case fascism
        case settings
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    switch selectedScreen {
                    case .home:
                        WeatherView()
                            .frame(height: 333)
                            .onAppear {
                                navigationVisible = .hidden
                                navigationTitle = "Weather"
                            }
                        Divider()
                        IncidenceView()
                            .frame(height: 267)
                        Divider()
                        LevelView()
                            .frame(height: 267)
                        Divider()
                        RadiationView()
                            .frame(height: 267)
                    case .weather:
                        ForecastView(header: "Temperature forecast (actual)", type: .actual)
                            .frame(height: 267)
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Weather Forecast"
                            }
                        Divider()
                        ForecastView(header: "Temperature forecast (feels like)", type: .apparent)
                            .frame(height: 267)
                    case .environment:
                        IncidenceView()
                            .frame(height: 267)
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Environmental Data"
                            }
                        Divider()
                        LevelView()
                            .frame(height: 267)
                        Divider()
                        RadiationView()
                            .frame(height: 267)
                    case .fascism:
                        FascismView()
                            .frame(height: 267)
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Election Polls"
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
                            Button(action: { selectedScreen = .fascism }) {
                                Image(systemName: selectedScreen == .fascism ? "theatermasks.fill" : "theatermasks")
                                    .foregroundColor(selectedScreen == .fascism ? .accentColor : .accentColor.opacity(0.5))
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(navigationVisible, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(
                Color(
                    uiColor: UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ? .black : .white
                    }), for: .navigationBar
            )
            .toolbarBackground(.visible, for: .bottomBar)
            .toolbarBackground(
                Color(
                    uiColor: UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ? .black : .white
                    }), for: .bottomBar
            )
            .refreshable {
            }
        }
    }
}
