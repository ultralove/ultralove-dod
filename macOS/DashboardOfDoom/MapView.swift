import MapKit
import SwiftUI

struct MapView: View {
    @Environment(WeatherViewModel.self) private var weather
    @Environment(IncidenceViewModel.self) private var incidence
    @Environment(LevelViewModel.self) private var level
    @Environment(RadiationViewModel.self) private var radiation
    @Environment(ParticleViewModel.self) private var particle
    @Environment(SurveyViewModel.self) private var survey

    private var viewModel = MapViewModel.shared

    //    private var cameraPosition: Binding<MapCameraPosition> {
    //        Binding(
    //            get: { self.viewModel.region },
    //            set: { self.viewModel.region = $0 }
    //        )
    //    }

    var body: some View {
        VStack {
            HeaderView(label: "Environmental conditions", sensor: weather.sensor)
            if weather.timestamp == nil {
                ActivityIndicator()
            }
            else {
                _view()
            }
            FooterView(sensor: weather.sensor)
        }
        .padding()
        .cornerRadius(13)
    }

    func _view() -> some View {
        VStack {
            Map(position: viewModel.binding(for: \.region), interactionModes: []) {
                if let coordinate = weather.sensor?.location.coordinate {
                    Annotation("", coordinate: coordinate, anchor: .center) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 20, height: 20)
                            Circle()
                                .fill(Color.faceplate)
                                .frame(width: 13, height: 13)
                        }
                    }
                    Annotation("", coordinate: weather.coordinate, anchor: .topTrailing) {
                        VStack {
                            Spacer()
                            Image(systemName: weather.symbol)
                                .font(.largeTitle)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(
                                    String(
                                        format: "\(GreekLetters.mathematicalBoldCapitalTau.rawValue): %.1f%@",
                                        weather.actualTemperature?.value ?? Double.nan, weather.actualTemperature?.unit.symbol ?? ""))
                            }
                            Spacer()
                        }
                        .frame(height: 57)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .fill(Color.faceplate)
                                .opacity(0.33)
                        )
                        .foregroundStyle(.black)
                    }
                }
                if let coordinate = incidence.sensor?.location.coordinate {
                    Annotation("", coordinate: coordinate, anchor: .center) {
                        Circle()
                            .fill(Color.faceplate)
                            .frame(width: 11, height: 11)
                    }
                    Annotation("", coordinate: coordinate, anchor: .bottomLeading) {
                        VStack {
                            Spacer()
                            Image(systemName: "facemask")
                                .font(.title)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(incidence.faceplate)
                            }
                            Spacer()
                        }
                        .frame(height: 57)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .fill(Color.faceplate)
                                .opacity(0.33)
                        )
                        .foregroundStyle(.black)
                    }
                }
                if let coordinate = particle.sensor?.location.coordinate {
                    Annotation("", coordinate: coordinate, anchor: .center) {
                        Circle()
                            .fill(Color.faceplate)
                            .frame(width: 11, height: 11)
                    }
                    Annotation("", coordinate: coordinate, anchor: .topLeading) {
                        VStack {
                            Spacer()
                            Image(systemName: "waveform.path.ecg")
                                .font(.title)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(particle.faceplate(selector: .pm10))
//                                Text(particle.faceplate(selector: .pm25))
//                                Text(particle.faceplate(selector: .no2))
                            }
                            Spacer()
                        }
                        .frame(height: 57)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .fill(Color.faceplate)
                                .opacity(0.33)
                        )
                        .foregroundStyle(.black)
                    }
                }
                if let coordinate = level.sensor?.location.coordinate {
                    Annotation("", coordinate: coordinate, anchor: .center) {
                        Circle()
                            .fill(Color.faceplate)
                            .frame(width: 11, height: 11)
                    }
                    Annotation("", coordinate: coordinate, anchor: .bottomLeading) {
                        VStack {
                            Spacer()
                            Image(systemName: "water.waves")
                                .font(.title)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(level.faceplate)
                            }
                            Spacer()
                        }
                        .frame(height: 57)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .fill(Color.faceplate)
                                .opacity(0.33)
                        )
                        .foregroundStyle(.black)
                    }
                }
                if let coordinate = radiation.sensor?.location.coordinate {
                    Annotation("", coordinate: coordinate, anchor: .center) {
                        Circle()
                            .fill(Color.faceplate)
                            .frame(width: 11, height: 11)
                    }
                    Annotation("", coordinate: coordinate, anchor: .bottomLeading) {
                        VStack {
                            Spacer()
                            Image(systemName: "atom")
                                .font(.title)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(radiation.faceplate)
                            }
                            Spacer()
                        }
                        .frame(height: 57)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .fill(Color.faceplate)
                                .opacity(0.33)
                        )
                        .foregroundStyle(.black)
                    }
                }
                if let coordinate = survey.sensor?.location.coordinate {
                    Annotation("", coordinate: coordinate, anchor: .center) {
                        Circle()
                            .fill(Color.faceplate)
                            .frame(width: 11, height: 11)
                    }
                    Annotation("", coordinate: coordinate, anchor: .bottomLeading) {
                        VStack {
                            Spacer()
                            Image(systemName: "popcorn")
                                .font(.title)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(survey.faceplate(selector: .fascists))
                            }
                            Spacer()
                        }
                        .frame(height: 57)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .fill(Color.faceplate)
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
