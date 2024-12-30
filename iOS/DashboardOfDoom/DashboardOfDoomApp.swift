import SwiftUI

@main
struct DashboardOfDoomApp: App {
    @State var weatherViewModel = WeatherViewModel()
    @State var forecastViewModel = ForecastViewModel()
    @State var incidenceViewModel = IncidenceViewModel()
    @State var radiationViewModel = RadiationViewModel()
    @State var levelViewModel = LevelViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(weatherViewModel)
                .environment(forecastViewModel)
                .environment(incidenceViewModel)
                .environment(radiationViewModel)
                .environment(levelViewModel)

        }
    }
}
