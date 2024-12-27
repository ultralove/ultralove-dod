import Charts
import MapKit
import SwiftUI

struct ContentView: View {
    @State private var viewModel = WeatherViewModel.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    WeatherView()
                        .padding()
                        .frame(height: 200)
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
                .frame(maxWidth: .infinity)
                .navigationTitle(viewModel.location?.name ?? "<Unknown>")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    ContentView()
}
