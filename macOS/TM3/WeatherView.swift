import MapKit
import SwiftUI

struct WeatherView: View {
    @Environment(WeatherViewModel.self) private var weather
    @Environment(IncidenceViewModel.self) private var incidence
    @Environment(LevelViewModel.self) private var level
    @Environment(RadiationViewModel.self) private var radiation

    //    private var cameraPosition: Binding<MapCameraPosition> {
    //        Binding(
    //            get: { self.viewModel.region },
    //            set: { self.viewModel.region = $0 }
    //        )
    //    }

    var body: some View {
        if weather.timestamp == nil {
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
            Map(position: weather.binding(for: \.region), interactionModes: [.all]) {
                UserAnnotation()
                Annotation(coordinate: weather.coordinate, anchor: .topLeading) {
                    VStack {
                        HStack {
                            Image(systemName: weather.conditionsSymbol)
                            Text(String(format: "%.1f%@", weather.actualTemperature?.value ?? Double.nan, weather.actualTemperature?.unit.symbol ?? ""))
                            Spacer()
                        }
                        .font(.title)
                        HStack {
                            Text("Feels like:")
                            Spacer()
                            Text(String(format: "%.1f%@", weather.apparentTemperature?.value ?? Double.nan, weather.apparentTemperature?.unit.symbol ?? ""))
                        }
                        .font(.footnote)
                        HStack {
                            Text("Humidity:")
                            Spacer()
                            Text(String(format: "%.1f%%", weather.humidity * 100))
                        }
                        .font(.footnote)
                        HStack {
                            Text("Pressure:")
                            Spacer()
                            Text(String(format: "%.1f%@", weather.pressure?.value ?? Double.nan, weather.pressure?.unit.symbol ?? ""))
                        }
                        .font(.footnote)
                    }
                    .padding(5)
                    .padding(.horizontal, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 13)
                            .opacity(0.125)
                    )
                    .foregroundStyle(.black)
                } label: {
                }
                if let coordinate = incidence.sensor?.location.coordinate {
                    Annotation(coordinate: coordinate, anchor: .center) {
                        Circle()
                            .fill(.blue)
//                            .opacity(0.67)
                            .frame(width: 11, height: 11)
                    } label: {
                    }
                    Annotation(coordinate: coordinate, anchor: .topLeading) {
                        Image(systemName: "facemask")
                            .font(.largeTitle)
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
                if let coordinate = level.sensor?.location.coordinate {
                    Annotation(coordinate: coordinate, anchor: .center) {
                        Circle()
                            .fill(.blue)
//                            .opacity(0.67)
                            .frame(width: 11, height: 11)
                    } label: {
                    }
                    Annotation(coordinate: coordinate, anchor: .topLeading) {
                        Image(systemName: "water.waves")
                            .font(.largeTitle)
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
                if let coordinate = radiation.sensor?.location.coordinate {
                    Annotation(coordinate: coordinate, anchor: .center) {
                        Circle()
                            .fill(.blue)
//                            .opacity(0.67)
                            .frame(width: 11, height: 11)
                    } label: {
                    }
                    Annotation(coordinate: coordinate, anchor: .topLeading) {
                        Image(systemName: "atom")
                            .font(.largeTitle)
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
            }
            HStack {
                Text("Last update: \(Date.absoluteString(date: weather.timestamp ?? Date.now))")
                    .font(.footnote)
                Spacer()
            }
        }
    }
}
