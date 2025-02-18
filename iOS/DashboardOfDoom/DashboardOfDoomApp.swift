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

    var body: some Scene {
        WindowGroup {
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
        }
    }
}
