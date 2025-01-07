import SwiftUI

@main
struct TM3App: App {
    @State var weatherViewModel = WeatherViewModel()
    @State var forecastViewModel = ForecastViewModel()
    @State var incidenceViewModel = IncidenceViewModel()
    @State var levelViewModel = LevelViewModel()
    @State var radiationViewModel = RadiationViewModel()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environment(weatherViewModel)
                .environment(forecastViewModel)
                .environment(incidenceViewModel)
                .environment(levelViewModel)
                .environment(radiationViewModel)
        } label: {
            Text(weatherViewModel.faceplate)
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
