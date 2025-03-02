import MapKit
import SwiftUI

struct Hotspots: MapContent {
    let hotspots: [Hotspot]
    let color: Color

    var body: some MapContent {
        ForEach(self.hotspots, id: \.id) { hotspot in
            Annotation("", coordinate: hotspot.location.coordinate, anchor: .center) {
                if self.color == .green {
                    Circle()
                        .fill(Color.blendedBlue)
                        .frame(width: 6, height: 6)

                }
                else {
                    Circle()
                        .fill(self.color.opacity(0.67))
                        .frame(width: 11, height: 11)

                }
            }
        }
    }
}

struct Faceplate: MapContent {
    let sensor: Sensor
    var user: Bool = false
    let label: String
    let icon: String
    let anchor: UnitPoint

    var body: some MapContent {
        Annotation("", coordinate: self.sensor.location.coordinate, anchor: .center) {
            if user == true {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
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
        Annotation("", coordinate: self.sensor.location.coordinate, anchor: self.anchor) {
            VStack {
                Spacer()
                if user == true {
                    Image(systemName: self.icon)
                        .font(.largeTitle)
                }
                else {
                    Image(systemName: self.icon)
                        .font(.title)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text(self.label)
                }
                Spacer()
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
        }
    }
}

struct MapView: View {
    @Environment(WeatherViewModel.self) private var weather
    @Environment(IncidenceViewModel.self) private var incidence
    @Environment(LevelViewModel.self) private var level
    @Environment(RadiationViewModel.self) private var radiation
    @Environment(ParticleViewModel.self) private var particle
    @Environment(HotspotViewModel.self) private var hotspots

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
                if let liquorStores = hotspots.liquorStores {
                    Hotspots(hotspots: liquorStores, color: .green)
                }
//                if let pharmacies = hotspots.pharmacies {
//                    Hotspots(hotspots: pharmacies, color: .orange)
//                }
                if let hospitals = hotspots.hospitals {
                    Hotspots(hotspots: hospitals, color: .red)
                }
                if let funeralDirectors = hotspots.funeralDirectors {
                    Hotspots(hotspots: funeralDirectors, color: .purple)
                }
                if let cemeteries = hotspots.cemeteries {
                    Hotspots(hotspots: cemeteries, color: .gray)
                }
                if let sensor = weather.sensor {
                    Faceplate(
                        sensor: sensor, user: true, label: weather.faceplate(selector: .actualTemperature), icon: weather.icon,
                        anchor: .topTrailing)
                }
                if let sensor = incidence.sensor {
                    Faceplate(sensor: sensor, label: incidence.faceplate, icon: incidence.icon, anchor: .bottomLeading)
                }
                if let sensor = particle.sensor {
                    Faceplate(sensor: sensor, label: particle.faceplate(), icon: particle.icon, anchor: .topLeading)
                }
                if let sensor = level.sensor {
                    Faceplate(sensor: sensor, label: level.faceplate, icon: level.icon, anchor: .bottomLeading)
                }
                if let sensor = radiation.sensor {
                    Faceplate(sensor: sensor, label: radiation.faceplate, icon: radiation.icon, anchor: .bottomLeading)
                }
            }
            .allowsHitTesting(false)
        }
    }
}
