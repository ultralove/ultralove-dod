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
    @State var colorPresenter = ColorPresenter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorPresenter.colorScheme)
                .tint(colorPresenter.tintColor)
                .environment(weatherViewModel)
                .environment(forecastPresenter)
                .environment(covidPresenter)
                .environment(levelPresenter)
                .environment(radiationPresenter)
                .environment(particlePresenter)
                .environment(surveyPresenter)
                .environment(colorPresenter)
        }
    }
}
