import MapKit
import SwiftUI

struct WeatherView: View {
    @Environment(WeatherViewModel.self) private var viewModel

    //    private var cameraPosition: Binding<MapCameraPosition> {
    //        Binding(
    //            get: { self.viewModel.region },
    //            set: { self.viewModel.region = $0 }
    //        )
    //    }

    var body: some View {
        if viewModel.timestamp == nil {
            ActivityIndicator()
        }
        else {
            _view()
        }
    }

    func _view() -> some View {
        VStack {
            HStack {
                Text(String(format: "Current weather conditions:"))
                Spacer()
            }
            let interactionModes: MapInteractionModes = []
            Map(position: viewModel.binding(for: \.region), interactionModes: interactionModes) {
                UserAnnotation()
                Annotation(coordinate: viewModel.coordinate, anchor: .topLeading) {
                    VStack {
                        HStack {
                            Image(systemName: viewModel.conditionsSymbol)
                            Text(String(format: "%.1f%@", viewModel.actualTemperature?.value ?? Double.nan, viewModel.actualTemperature?.unit.symbol ?? ""))
                            Spacer()
                        }
                        .font(.title)
                        HStack {
                            Text("Feels like:")
                            Spacer()
                            Text(String(format: "%.1f%@", viewModel.apparentTemperature?.value ?? Double.nan, viewModel.apparentTemperature?.unit.symbol ?? ""))
                        }
                        .font(.footnote)
                        HStack {
                            Text("Humidity:")
                            Spacer()
                            Text(String(format: "%.1f%%", viewModel.humidity * 100))
                        }
                        .font(.footnote)
                        HStack {
                            Text("Pressure:")
                            Spacer()
                            Text(String(format: "%.1f%@", viewModel.pressure?.value ?? Double.nan, viewModel.pressure?.unit.symbol ?? ""))
                        }
                        .font(.footnote)
                    }
                    .padding()
                    .padding(5)
                    .padding(.horizontal, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 13)
                            .opacity(0.125)
                    )
                    .foregroundStyle(.black)
                } label: {
                }
            }
            HStack {
                Text("Last update: \(Date.absoluteString(date: viewModel.timestamp ?? Date.now))")
                    .font(.footnote)
                Spacer()
            }
        }
    }
}

