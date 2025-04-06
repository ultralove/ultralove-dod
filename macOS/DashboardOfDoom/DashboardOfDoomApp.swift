import AppKit
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
    @State var pointOfInterestViewModel = PointOfInterestViewModel()

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
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
                .environment(pointOfInterestViewModel)

        } label: {
            Text(weatherViewModel.faceplate[.weather(.temperature)] ?? "n/a")
                .font(.system(.body, design: .monospaced))
        }
        .menuBarExtraStyle(.window)
        #if os(macOS)
//        Settings {
//            SettingsView()
//        }
        #endif
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Force the appearance for the entire application
        NSApp.appearance = NSAppearance(named: .darkAqua)

        // Make sure any new windows/popovers also use dark mode
        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: nil
        ) { notification in
            if let window = notification.object as? NSWindow {
                window.appearance = NSAppearance(named: .darkAqua)
            }
        }
    }
}

