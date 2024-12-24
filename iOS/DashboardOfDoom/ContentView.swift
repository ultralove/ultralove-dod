import Charts
import MapKit
import SwiftUI

struct ContentView: View {
    @State private var viewModel = WeatherViewModel.shared

    var body: some View {
        HStack {
            Text(String(format: "%@", viewModel.location?.name ?? "<Unknown>"))
                .font(.headline)
        }
        .padding()
        .frame(height: 34)
        WeatherView()
            .padding()
        ForecastView()
            .padding()
        IncidenceView()
            .padding()
        RadiationView()
            .padding()
    }
}

#Preview {
    ContentView()
}
