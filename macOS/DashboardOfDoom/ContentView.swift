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

struct ContentView: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(\.colorScheme) var colorScheme
    @Environment(WeatherViewModel.self) private var viewModel
    @Environment(CovidViewModel.self) private var covidPresenter

    var body: some View {
        VStack {
            HStack {
                Image("dashboard-of-doom-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 34)
                    .padding(.top, 10)
                Spacer()
                HStack {
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
                    SensorPanel(label: "Weather Forecast", icon: "cloud.sun") {
                        ForecastView(header: "Temperature (actual)", selector: .temperature)
                            .frame(height: 200)
                        ForecastView(header: "Temperature (feels like)", selector: .apparentTemperature)
                            .frame(height: 200)
                        ForecastView(header: "Dew point", selector: .dewPoint)
                            .frame(height: 200)
                        ForecastView(header: "Humidity", selector: .humidity)
                            .frame(height: 200)
                        ForecastView(header: "Precipitation chance", selector: .precipitationChance)
                            .frame(height: 200)
                        ForecastView(header: "Precipitation amount", selector: .precipitationAmount)
                            .frame(height: 200)
                        ForecastView(header: "Pressure", selector: .pressure)
                            .frame(height: 200)
                        ForecastView(header: "Visibility", selector: .visibility)
                            .frame(height: 200)
                        ForecastView(header: "Cloud Cover", selector: .cloudCover)
                            .frame(height: 200)
                        ForecastView(header: "Wind Speed", selector: .windSpeed)
                            .frame(height: 200)
                        ForecastView(header: "Wind Gusts", selector: .windGust)
                            .frame(height: 200)
                    }
                    Divider()
                    SensorPanel(label: "COVID-19", icon: "facemask") {
                        ForEach(ProcessSelector.Covid.allCases, id: \.self) { selector in
                            CovidView(selector: .covid(selector))
                                .frame(height: 200)
                        }
                    }
                    Divider()
                    SensorPanel(label: "Water Level", icon: "water.waves") {
                        LevelView(label: "Water Level", selector: .water(.level))
                            .padding(.vertical, 5)
                            .frame(height: 200)
                    }
                    Divider()
                    SensorPanel(label: "Radiation", icon: "atom") {
                        RadiationView(label: "Radiation", selector: .radiation(.total))
                            .padding(.vertical, 5)
                            .frame(height: 200)
                    }
                    Divider()
                    SensorPanel(label: "Particulate Matter", icon: "aqi.medium") {
                        ParticleView(selector: .pm10)
                            .frame(height: 200)
                        ParticleView(selector: .pm25)
                            .frame(height: 200)
                        ParticleView(selector: .no2)
                            .frame(height: 200)
                    }
                    Divider()
                    SensorPanel(label: "Election Polls", icon: "popcorn") {
                        SurveyView(header: "Fascists vote share in", selector: .fascists)
                            .padding(.vertical, 5)
                            .frame(height: 200)
                        SurveyView(header: "Clowns vote share in", selector: .clowns)
                            .padding(.vertical, 5)
                            .frame(height: 200)
                        SurveyView(header: "Die Linke vote share in", selector: .linke)
                            .padding(.vertical, 5)
                            .frame(height: 200)
                        SurveyView(header: "Die Grünen vote share in", selector: .gruene)
                            .padding(.vertical, 5)
                            .frame(height: 200)
                        SurveyView(header: "SPD vote share in", selector: .spd)
                            .padding(.vertical, 5)
                            .frame(height: 200)
                        SurveyView(header: "AfD vote share in", selector: .afd)
                            .padding(.vertical, 5)
                            .frame(height: 200)
                        SurveyView(header: "FDP vote share in", selector: .fdp)
                            .padding(.vertical, 5)
                            .frame(height: 200)
                        SurveyView(header: "BSW vote share in", selector: .bsw)
                            .padding(.vertical, 5)
                            .frame(height: 200)
                        SurveyView(header: "CDU/CSU vote share in", selector: .cducsu)
                            .padding(.vertical, 5)
                            .frame(height: 200)
                        SurveyView(header: "Sonstige vote share in", selector: .sonstige)
                            .padding(.vertical, 5)
                            .frame(height: 200)
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
