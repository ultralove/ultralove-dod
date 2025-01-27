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
                        .frame(height: 333)
                    Divider()
                    ForecastView()
                        .frame(height: 267)
                    Divider()
                    IncidenceView()
                        .frame(height: 267)
                    Divider()
                    LevelView()
                        .frame(height: 267)
                    Divider()
                    RadiationView()
                        .frame(height: 267)
                    Divider()
                    FascismView()
                        .frame(height: 267)
                }
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {}) {
                            Image(systemName: "gearshape")
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "map")
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "stethoscope")
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "water.waves")
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "atom")
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "popcorn")
                            }
                        }
                    }
                }
            }
            .accentColor(.cyan)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.black, for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
        }
    }
}
