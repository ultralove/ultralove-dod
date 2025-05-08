import MapKit
import SwiftUI

struct Faceplate: MapContent {
    let sensor: ProcessSensor
    var user: Bool = false
    let label: String?
    let icon: String?
    let anchor: UnitPoint

    var body: some MapContent {
        Annotation("", coordinate: self.sensor.location.coordinate, anchor: self.anchor) {
            #if os(iOS)
            VStack {
                Spacer()
                if let icon = self.icon {
                    if user == true {
                        Image(systemName: icon)
                    }
                    else {
                        Image(systemName: icon)
                    }
                }
                Spacer()
                if let label = self.label {
                    VStack(alignment: .leading) {
                        Text(label)
                            .font(.footnote)
                    }
                    Spacer()
                }
            }
            .padding(5)
            .padding(.horizontal, 5)
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color.faceplate)
                    .opacity(0.33)
            )
            .font(.title)
            .foregroundStyle(.black)
            #else
            VStack {
                Spacer()
                if let icon = self.icon {
                    if user == true {
                        Image(systemName: icon)
                            .font(.largeTitle)
                    }
                    else {
                        Image(systemName: icon)
                            .font(.title)
                    }
                }
                Spacer()
                if let label = self.label {
                    VStack(alignment: .leading) {
                        Text(label)
                    }
                    Spacer()
                }
            }
            .frame(height: 57)
            .padding(5)
            .padding(.horizontal, 5)
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color.faceplate)
                    .opacity(0.77)
            )
            .foregroundStyle(.black)
            #endif
        }
        Annotation("", coordinate: self.sensor.location.coordinate, anchor: .center) {
            VStack {
                if user == true {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 15, height: 15)
                        Circle()
                            .fill(Color.location)
                            .frame(width: 11, height: 11)
                    }
                }
                else {
                    Circle()
                        .fill(Color.location)
                        .frame(width: 11, height: 11)

                }
            }
        }
    }
}

struct MapView: View {
    @Environment(WeatherPresenter.self) private var weather
    @Environment(CovidPresenter.self) private var incidence
    @Environment(LevelPresenter.self) private var water
    @Environment(RadiationPresenter.self) private var radiation
    @Environment(ParticlePresenter.self) private var particle
    @Environment(SurveyPresenter.self) private var surveys

    private var viewModel = MapPresenter.shared

    //    private var cameraPosition: Binding<MapCameraPosition> {
    //        Binding(
    //            get: { self.viewModel.region },
    //            set: { self.viewModel.region = $0 }
    //        )
    //    }

    var body: some View {
        VStack {
            if let sensor = weather.sensor {
                #if os(macOS)
                HStack(alignment: .bottom) {
                    Image(systemName: "safari")
                    Text(String(format: "%@", sensor.placemark ?? "<Unknown>"))
                    Spacer()
                    Text("Last update: \(Date.absoluteString(date: sensor.timestamp))")
                        .foregroundColor(.gray)

                }
                .padding(.vertical, 5)
                .padding(.leading, 5)
                .font(.footnote)
                #else
                VStack(alignment: .leading) {
                    HStack(alignment: .bottom) {
                        Image(systemName: "safari")
                        Text(String(format: "%@", sensor.placemark ?? "<Unknown>"))
                        Spacer()
                    }
                    HStack {
                        Text("Last update: \(Date.absoluteString(date: sensor.timestamp))")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .font(.footnote)
                #endif
            }

            if weather.timestamp == nil {
                ActivityIndicator()
            }
            else {
                _view()
            }
        }
    }

    func _view() -> some View {
        VStack {
            Map(position: viewModel.binding(for: \.region), interactionModes: []) {
                MapAnnotation(presenter: weather, selector: .weather(.temperature), user:true, anchor: .topTrailing)
                MapAnnotation(presenter: incidence, selector: .covid(.incidence), anchor: .bottomLeading)
                MapAnnotation(presenter: particle, selector: .particle(.pm10), anchor: .bottomTrailing)
                MapAnnotation(presenter: water, selector: .water(.level), anchor: .bottomLeading)
                MapAnnotation(presenter: radiation, selector: .radiation(.total), anchor: .bottomLeading)
                MapAnnotation(presenter: surveys, selector: .survey(.fascists), anchor: .topLeading)
            }
            .allowsHitTesting(false)
        }
    }
}
