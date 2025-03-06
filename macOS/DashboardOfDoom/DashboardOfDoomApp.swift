import SwiftUI

@main
struct DashboardOfDoomApp: App {
    @State var weatherViewModel = WeatherViewModel()
    @State var forecastViewModel = ForecastViewModel()
    @State var incidenceViewModel = IncidenceViewModel()
    @State var levelViewModel = LevelViewModel()
    @State var radiationViewModel = RadiationViewModel()
    @State var particleViewModel = ParticleViewModel()
    @State var surveyViewModel = SurveyViewModel()
    @State var pointOfInterestViewModel = PointOfInterestViewModel()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .preferredColorScheme(.dark) 
//                .accentColor(.init(light: .blue, dark: .orange))
                .environment(weatherViewModel)
                .environment(forecastViewModel)
                .environment(incidenceViewModel)
                .environment(levelViewModel)
                .environment(radiationViewModel)
                .environment(particleViewModel)
                .environment(surveyViewModel)
                .environment(pointOfInterestViewModel)

        } label: {
            Text(weatherViewModel.faceplate(selector: .actualTemperature))
                .font(.system(.body, design: .monospaced))
        }
        .menuBarExtraStyle(.window)
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
