import MapKit
import SwiftUI

struct PointOfInterestView: MapContent {
    let pointOfInterest: PointOfInterest
    let color: Color

    @State var showingSheet = false

    var body: some MapContent {
        Annotation("", coordinate: pointOfInterest.location.coordinate, anchor: .center) {
            VStack {
                if self.color == .green {
                    Circle()
                        //                        .fill(Color.blendedBlue)
                        //                        .fill(Color.blue.opacity(0.5))
                        .fill(Color.spaeti)
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

    @State var showingSheet = false

    var body: some MapContent {
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

struct Faceplate2: MapContent {
    let sensor: ProcessSensor
    var user: Bool = false
    let label: String?
    let icon: String?
    let anchor: UnitPoint

    var body: some MapContent {
        Annotation("", coordinate: self.sensor.location.coordinate, anchor: .center) {
            VStack {
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
        }
        Annotation("", coordinate: self.sensor.location.coordinate, anchor: self.anchor) {
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
        }
    }
}

struct PulsatingImage: View {
    let systemName: String
    let scale: ClosedRange<Double>
    let opacity: ClosedRange<Double>
    let duration: Double
    @State private var isPulsing = false

    init(
        systemName: String = "heart.fill", scale: ClosedRange<Double> = 1.0 ... 1.1, opacity: ClosedRange<Double> = 0.9 ... 1.0,
        duration: Double = 3.0
    ) {
        self.systemName = systemName
        self.scale = scale
        self.opacity = opacity
        self.duration = duration
    }

    var body: some View {
        ZStack {
            Image(systemName: systemName)
                .scaleEffect(isPulsing ? self.scale.upperBound : self.scale.lowerBound)
                .opacity(isPulsing ? self.opacity.upperBound : self.opacity.lowerBound)
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: self.duration)
                    .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
    }
}

struct MapView: View {
    @Environment(WeatherViewModel.self) private var weather
    @Environment(CovidPresenter.self) private var incidence
    @Environment(LevelPresenter.self) private var water
    @Environment(RadiationPresenter.self) private var radiation
    @Environment(ParticlePresenter.self) private var particle
    @Environment(SurveyPresenter.self) private var surveys
    @Environment(PointOfInterestViewModel.self) private var pointsOfInterest

    private var viewModel = MapViewModel.shared

    //    private var cameraPosition: Binding<MapCameraPosition> {
    //        Binding(
    //            get: { self.viewModel.region },
    //            set: { self.viewModel.region = $0 }
    //        )
    //    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "stethoscope")
                    .imageScale(.large)
                    .frame(width: 23)
                Text("Environmental conditions:")
                Spacer()
            }
            .fontWeight(.light)

            if let sensor = weather.sensor {
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
            }

            if weather.timestamp == nil {
                ActivityIndicator()
            }
            else {
                _view()
            }
        }
        .padding(.horizontal)
        .cornerRadius(13)
    }

    func _view() -> some View {
        VStack {
            Map(position: viewModel.binding(for: \.region), interactionModes: []) {
                if let liquorStores = pointsOfInterest.liquorStores {
                    ForEach(liquorStores, id: \.id) { liquorStore in
                        PointOfInterestView(pointOfInterest: liquorStore, color: .green)
                    }
                }
                //                if let pharmacies = parsePointsOfInterest.pharmacies {
                //                    ForEach(pharmacies, id: \.id) { pharmacy in
                //                        PointOfInterestView(pointOfInterest: pharmacy, color: .orange)
                //                    }
                //                }
                if let hospitals = pointsOfInterest.hospitals {
                    ForEach(hospitals, id: \.id) { hospital in
                        PointOfInterestView(pointOfInterest: hospital, color: .red)
                    }
                }
                if let funeralDirectors = pointsOfInterest.funeralDirectors {
                    ForEach(funeralDirectors, id: \.id) { funeralDirector in
                        PointOfInterestView(pointOfInterest: funeralDirector, color: .purple)
                    }
                }
                if let cemeteries = pointsOfInterest.cemeteries {
                    ForEach(cemeteries, id: \.id) { cemetery in
                        PointOfInterestView(pointOfInterest: cemetery, color: .gray)
                    }
                }
                if let sensor = weather.sensor {
                    Faceplate(
                        sensor: sensor, user: true, label: weather.faceplate(selector: .actualTemperature), icon: weather.icon,
                        anchor: .topTrailing)
                }
                if let sensor = incidence.sensor {
                    Faceplate2(sensor: sensor, label: incidence.faceplate[.covid(.incidence)], icon: incidence.icon, anchor: .bottomLeading)
                }
                if let sensor = particle.sensor {
                    Faceplate2(sensor: sensor, label: particle.faceplate[.particle(.pm10)], icon: particle.icon, anchor: .topLeading)
                }
                if let sensor = water.sensor {
                    Faceplate2(sensor: sensor, label: water.faceplate[.water(.level)], icon: water.icon, anchor: .bottomLeading)
                }
                if let sensor = radiation.sensor {
                    Faceplate2(sensor: sensor, label: radiation.faceplate[.radiation(.total)], icon: radiation.icon, anchor: .bottomLeading)
                }
                //                if let sensor = surveys.sensor {
                //                    Faceplate(sensor: sensor, label: surveys.faceplate(selector: .fascists), icon: surveys.icon, anchor: .bottomLeading)
                //                }
            }
            .allowsHitTesting(false)
        }
    }
}
