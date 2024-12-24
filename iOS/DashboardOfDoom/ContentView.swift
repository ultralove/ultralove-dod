import CoreLocation
import SwiftUI

struct ContentView: View {
    @State private var weatherManager = WeatherManager()

    let jakarta = CLLocation(latitude: -6.21462, longitude: 106.84513)

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: weatherManager.icon)
                .font(.largeTitle)
                .shadow(radius: 2)
                .padding()
            Text("Temperature: \(weatherManager.temperature)")
                .shadow(radius: 1)
            Text("Apparent Temperature: \(weatherManager.apparentTemperature)")
                .shadow(radius: 1)
            Text("Humidity: \(weatherManager.humidity)")
                .shadow(radius: 1)
        }
        .onAppear {
            Task {
                await weatherManager.getWeather(
                    lat: jakarta.coordinate.latitude,
                    long: jakarta.coordinate.longitude)
            }
        }
        .font(.title3)
    }
}

#Preview {
    ContentView()
}
