import SwiftUI

@main
struct DashboardOfDoomApp: App {
    @State var weatherViewModel = WeatherViewModel()
    @State var forecastViewModel = ForecastViewModel()
    @State var incidenceViewModel = IncidenceViewModel()
    @State var radiationViewModel = RadiationViewModel()
    @State var levelViewModel = LevelViewModel()
    @State var fascismViewModel = FascismViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(weatherViewModel)
                .environment(forecastViewModel)
                .environment(incidenceViewModel)
                .environment(radiationViewModel)
                .environment(levelViewModel)
                .environment(fascismViewModel)
        }
    }
}
