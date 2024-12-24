import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("startAtLogin") private var startAtLogin = false

    var body: some View {
        Form {
        }
        Spacer()
    }
}

struct WeatherSettingsView: View {
    var body: some View {
        Form {
        }
        Spacer()
    }
}

struct IncidenceSettingsView: View {
    @AppStorage("incidenceHistoryLength") private var historyLength = 100.0
    @AppStorage("incidenceForecastLength") private var forecastLength = 50.0
    @AppStorage("incidenceUpdateInterval") private var updateInterval = 50.0

    var body: some View {
        Form {
            Slider(value: $historyLength, in: 1...1000) {
                Text("History: \(historyLength) days")
            }
            Slider(value: $forecastLength, in: 1...100) {
                Text("Forecast: \(forecastLength)")
            }
            Slider(value: $updateInterval, in: 1...100) {
                Text("Update interval: \(updateInterval)")
            }
        }
        Spacer()
    }
}

struct RadiationSettingsView: View {
    @AppStorage("radiationHistoryLength") private var historyLength = 100.0
    @AppStorage("radiationForecastLength") private var forecastLength = 50.0
    @AppStorage("radioationUpdateInterval") private var updateInterval = 50.0

    var body: some View {
        Form {
            Slider(value: $historyLength, in: 1...100) {
                Text("History: \(historyLength) days")
            }
            Slider(value: $forecastLength, in: 1...50) {
                Text("Forecast: \(forecastLength)")
            }
            Slider(value: $updateInterval, in: 1...100) {
                Text("Update interval: \(updateInterval)")
            }
        }
        Spacer()
    }
}

struct AboutView: View {
    var body: some View {
        Form {
        }
        Spacer()
    }
}


struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                GeneralSettingsView()
            }
            Tab("Weather", systemImage: "cloud.sun") {
                WeatherSettingsView()
            }
            Tab("COVID-19", systemImage: "facemask") {
                IncidenceSettingsView()
            }
            Tab("Radiation", systemImage: "bonjour") {
                RadiationSettingsView()
            }
//            Tab("Radiation", systemImage: "stethoscope") {
//                RadiationSettingsView()
//            }
            Tab("About", systemImage: "info.bubble") {
                AboutView()
            }
        }
        .tabViewStyle(.tabBarOnly)
        .scenePadding()
        .frame(maxWidth: 400, minHeight: 300)
    }
}

#Preview {
    SettingsView()
}
