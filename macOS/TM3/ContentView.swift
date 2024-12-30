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
                Text(String(format: "%@", viewModel.location?.name ?? "<Unknown>"))
                    .font(.headline)
                Spacer()
                HStack {
                    Button {
                        openSettings()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .imageScale(.large)
                    }
                    .buttonStyle(GrowingButton())
                    .focusable(false)
                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Image(systemName: "power")
                            .imageScale(.medium)
                    }
                    .buttonStyle(GrowingButton())
                    .focusable(false)
                }
            }
            .padding()
            .frame(height: 34)
            WeatherView()
                .padding([.leading, .trailing, .bottom])
            ForecastView()
                .padding()
                .frame(height: 200)
            IncidenceView()
                .padding()
                .frame(height: 200)
            RadiationView()
                .padding()
                .frame(height: 200)
        }
        .frame(width: 768, height: 1024)
    }
}

#Preview {
    ContentView()
}
