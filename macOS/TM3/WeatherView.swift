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
        VStack {
            HeaderView(label: "Environmental conditions for", sensor: weather.sensor)
            if weather.timestamp == nil {
                ActivityIndicator()
            }
            else {
                _view()
            }
            FooterView(sensor: weather.sensor)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(13)
    }

    func _view() -> some View {
        VStack {
            Map(position: weather.binding(for: \.region), interactionModes: []) {
                UserAnnotation()
                Annotation("", coordinate: weather.coordinate, anchor: .topTrailing) {
                    VStack {
                        HStack {
                            Image(systemName: weather.symbol)
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
                            .fill(.blue)
                            .opacity(0.33)
                    )
                    .foregroundStyle(.black)
                }
                if let coordinate = incidence.sensor?.location.coordinate {
                    Annotation("", coordinate: coordinate, anchor: .center) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 11, height: 11)
                    }
                    Annotation("", coordinate: coordinate, anchor: .bottomLeading) {
                        VStack {
                            Image(systemName: "facemask")
                                .font(.largeTitle)
                            Text(incidence.faceplate)
                        }
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .fill(.blue)
                                .opacity(0.33)
                        )
                        .foregroundStyle(.black)
                    }
                }
                if let coordinate = level.sensor?.location.coordinate {
                    Annotation("", coordinate: coordinate, anchor: .center) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 11, height: 11)
                    }
                    Annotation("",coordinate: coordinate, anchor: .bottomLeading) {
                        VStack {
                            Image(systemName: "water.waves")
                                .font(.largeTitle)
                            Text(level.faceplate)
                        }
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .fill(.blue)
                                .opacity(0.33)
                        )
                        .foregroundStyle(.black)
                    }
                }
                if let coordinate = radiation.sensor?.location.coordinate {
                    Annotation("", coordinate: coordinate, anchor: .center) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 11, height: 11)
                    }
                    Annotation("", coordinate: coordinate, anchor: .bottomLeading) {
                        VStack {
                            Image(systemName: "atom")
                                .font(.largeTitle)
                            Text(radiation.faceplate)
                        }
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .fill(.blue)
                                .opacity(0.33)
                        )
                        .foregroundStyle(.black)
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }
}
