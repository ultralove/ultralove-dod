import SwiftUI

@main
struct DashboardOfDoomApp: App {
    @State var weatherViewModel = WeatherViewModel()
    @State var forecastViewModel = ForecastViewModel()
    @State var incidenceViewModel = IncidenceViewModel()
    @State var radiationViewModel = RadiationViewModel()
    @State var levelViewModel = LevelViewModel()
    @State var surveyViewModel = SurveyViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) 
                .environment(weatherViewModel)
                .environment(forecastViewModel)
                .environment(incidenceViewModel)
                .environment(radiationViewModel)
                .environment(levelViewModel)
                .environment(surveyViewModel)
        }
    }
}
