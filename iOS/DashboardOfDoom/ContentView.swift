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
                        .padding()
                        .frame(height: 300)
                    ForecastView()
                        .padding()
                        .frame(height: 200)
                    IncidenceView()
                        .padding()
                        .frame(height: 200)
                    LevelView()
                        .padding()
                        .frame(height: 200)
                    RadiationView()
                        .padding()
                        .frame(height: 200)
                }
                .frame(maxWidth: .infinity)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text(viewModel.placemark ?? "<Unknown>")
                                .font(.footnote)
                                .lineLimit(1)
                            Spacer()
                            Button(action: { }) {
                                Image(systemName: "gear")
                            }
                        }
                    }
                }
            }
        }
    }
}

