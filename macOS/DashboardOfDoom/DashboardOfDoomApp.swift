import AppKit
import SwiftUI

@main
struct DashboardOfDoomApp: App {
    @State var weatherViewModel = WeatherViewModel()
    @State var forecastViewModel = ForecastViewModel()
    @State var incidenceViewModel = CovidPresenter()
    @State var levelViewModel = LevelPresenter()
    @State var radiationViewModel = RadiationPresenter()
    @State var particleViewModel = ParticlePresenter()
    @State var surveyViewModel = SurveyViewModel()
    @State var pointOfInterestViewModel = PointOfInterestViewModel()

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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

