import Charts
import MapKit
import SwiftUI

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.black)
            .scaleEffect(configuration.isPressed ? 1.75 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ContentView: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(WeatherViewModel.self) private var viewModel

    var body: some View {
        VStack {
            HStack {
                Text(String(format: "%@", viewModel.sensor?.placemark ?? "<Unknown>"))
                    .font(.headline)
                Spacer()
                HStack {
                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                    .buttonStyle(GrowingButton())
                    .focusable(false)
                }
            }
            .padding()
            .frame(height: 34)
            ScrollView {
                VStack {
                    WeatherView()
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 500)
                    ForecastView()
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    IncidenceView()
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    LevelView()
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    RadiationView()
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                    FascismView()
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(height: 200)
                }
            }
        }
        .frame(width: 768, height: 1024)
    }
}

#Preview {
    ContentView()
}
