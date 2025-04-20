import SwiftUI

@main
struct DashboardOfDoomApp: App {
    @State var weatherViewModel = WeatherPresenter()
    @State var forecastPresenter = ForecastPresenter()
    @State var covidPresenter = CovidPresenter()
    @State var levelPresenter = LevelPresenter()
    @State var radiationPresenter = RadiationPresenter()
    @State var particlePresenter = ParticlePresenter()
    @State var surveyPresenter = SurveyPresenter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) 
//                .accentColor(.init(light: .blue, dark: .orange))
                .environment(weatherViewModel)
                .environment(forecastPresenter)
                .environment(covidPresenter)
                .environment(levelPresenter)
                .environment(radiationPresenter)
                .environment(particlePresenter)
                .environment(surveyPresenter)
        }
    }
}
