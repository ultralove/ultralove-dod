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
                        VStack {
                            MapView()
                                .frame(height: 333)
                            Divider()
                            IncidenceView()
                                .frame(height: 267)
                            Divider()
                            LevelView()
                                .frame(height: 267)
                            Divider()
                            RadiationView()
                                .frame(height: 267)
                        }
                        .onAppear {
                            navigationVisible = .visible
                            navigationTitle = "Home"
                        }
                    case .weather:
                        VStack {
                            ForecastView(header: "Temperature (actual)", selector: .actual)
                                .frame(height: 267)
                            Divider()
                            ForecastView(header: "Temperature (feels like)", selector: .apparent)
                                .frame(height: 267)
                            Divider()
                            ForecastView(header: "Dew point", selector: .dewPoint)
                                .frame(height: 267)
                            Divider()
                            ForecastView(header: "Humidity", selector: .humidity)
                                .frame(height: 233)
                            Divider()
                            ForecastView(header: "Precipitation chance", selector: .precipitationChance)
                                .frame(height: 233)
                            Divider()
                            ForecastView(header: "Precipitation amount", selector: .precipitationAmount)
                                .frame(height: 233)
                            Divider()
                            ForecastView(header: "Pressure", selector: .pressure)
                                .frame(height: 233)
                            Divider()
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
                                .frame(height: 267)
                            Divider()
                            LevelView()
                                .frame(height: 267)
                            Divider()
                            RadiationView()
                                .frame(height: 267)
                        }
                        .onAppear {
                            navigationVisible = .visible
                            navigationTitle = "Environmental data"
                        }
                    case .fascism:
                        VStack {
                            SurveyView(header: "Fascists vote share in", selector: .fascists)
                                .frame(height: 267)
                            Divider()
                            SurveyView(header: "Clowns vote share in", selector: .clowns)
                                .frame(height: 267)
                            Divider()
                            SurveyView(header: "Die Linke vote share in", selector: .linke)
                                .frame(height: 267)
                            Divider()
                            SurveyView(header: "Die Grünen vote share in", selector: .gruene)
                                .frame(height: 267)
                            Divider()
                            SurveyView(header: "SPD vote share in", selector: .spd)
                                .frame(height: 267)
                            Divider()
                            SurveyView(header: "AfD vote share in", selector: .afd)
                                .frame(height: 267)
                            Divider()
                            SurveyView(header: "FDP vote share in", selector: .fdp)
                                .frame(height: 267)
                            Divider()
                            SurveyView(header: "BSW vote share in", selector: .bsw)
                                .frame(height: 267)
                            Divider()
                            SurveyView(header: "CDU/CSU vote share in", selector: .cducsu)
                                .frame(height: 267)
                            Divider()
                            SurveyView(header: "Sonstige vote share in", selector: .sonstige)
                                .frame(height: 267)
                        }
                        .onAppear {
                            navigationVisible = .visible
                            navigationTitle = "Election polls"
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
            .toolbar(.hidden, for: .navigationBar)
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar(navigationVisible, for: .navigationBar)
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbarBackground(
//                Color(
//                    uiColor: UIColor { traitCollection in
//                        traitCollection.userInterfaceStyle == .dark ? .black : .white
//                    }), for: .navigationBar
//            )
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
