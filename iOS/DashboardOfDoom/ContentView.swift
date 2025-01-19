import Charts
import MapKit
import SwiftUI

struct ContentView: View {
    @Environment(WeatherViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    WeatherView()
                        .padding(.vertical, 5)
                        .frame(height: 300)
                    ForecastView()
                        .padding(.vertical, 5)
                        .frame(height: 200)
                    IncidenceView()
                        .padding(.vertical, 5)
                        .frame(height: 200)
                    LevelView()
                        .padding(.vertical, 5)
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
                .frame(maxWidth: .infinity)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text(viewModel.placemark ?? "<Unknown>")
                                .font(.headline)
                                .lineLimit(1)
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "gearshape")
                            }
                        }
                    }
                }
            }
        }
    }
}
