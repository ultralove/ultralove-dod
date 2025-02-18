import SwiftUI
import LaunchAtLogin

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
//            .foregroundStyle(.black)
//            .scaleEffect(configuration.isPressed ? 1.75 : 1.0)
//            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ContentView: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(\.colorScheme) var colorScheme
    @Environment(WeatherViewModel.self) private var viewModel

    var body: some View {
        VStack {
            HStack {
                Text(String(format: "%@", viewModel.sensor?.placemark ?? "<Unknown>"))
                    .font(.headline)
                Spacer()
                HStack {
                    Menu() {
                        Button("Settings...") {
                            openSettings()
                        }
                        .keyboardShortcut(",", modifiers: .command)
                        .disabled(true)
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
                        .padding(.horizontal)
                        .frame(height: 500)
                    IncidenceView()
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    LevelView()
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    RadiationView()
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    ParticleView(header: "PM\u{2081}\u{2080} at ", selector: .pm10)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    ParticleView(header: "PM\u{2082}\u{2085} at ", selector: .pm25)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    ParticleView(header: "NO\u{2082} at ", selector: .no2)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    ForecastView(header: "Temperature (actual)", selector: .actual)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    ForecastView(header: "Temperature (feels like)", selector: .apparent)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    ForecastView(header: "Dew point", selector: .dewPoint)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    ForecastView(header: "Humidity", selector: .humidity)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    ForecastView(header: "Precipitation chance", selector: .precipitationChance)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    ForecastView(header: "Precipitation amount", selector: .precipitationAmount)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    ForecastView(header: "Pressure", selector: .pressure)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    ForecastView(header: "Visibility", selector: .visibility)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    SurveyView(header: "Fascists vote share in", selector: .fascists)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    SurveyView(header: "Clowns vote share in", selector: .clowns)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    SurveyView(header: "Die Linke vote share in", selector: .linke)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    SurveyView(header: "Die Grünen vote share in", selector: .gruene)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    SurveyView(header: "SPD vote share in", selector: .spd)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    SurveyView(header: "AfD vote share in", selector: .afd)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    SurveyView(header: "FDP vote share in", selector: .fdp)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    SurveyView(header: "BSW vote share in", selector: .bsw)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    SurveyView(header: "CDU/CSU vote share in", selector: .cducsu)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    SurveyView(header: "Sonstige vote share in", selector: .sonstige)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                }
            }

        }
        .frame(width: 768, height: 1024)
        .preferredColorScheme(.dark)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .foregroundStyle(colorScheme == .dark ? Color.cyan : Color.black)
    }
}

