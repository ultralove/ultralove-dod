import Charts
import SwiftUI

struct ParticleChart: View {
    @Environment(ParticleViewModel.self) private var viewModel
    @State private var timestamp: Date?
    let selector: ProcessSelector
    let rounding: RoundingStrategy

    var body: some View {
        VStack {
            Chart {
                ForEach(viewModel.measurements[selector] ?? []) { measurement in
                    if selector == .particle(.pm10) {
                        LineMark(
                            x: .value("Date", measurement.timestamp),
                            y: .value("Particle", 40.0)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(.black.opacity(0.33))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                    else if selector == .particle(.pm25) {
                        LineMark(
                            x: .value("Date", measurement.timestamp),
                            y: .value("Particle", 25.0)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(.black.opacity(0.33))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                    else if selector == .particle(.no2) {
                        LineMark(
                            x: .value("Date", measurement.timestamp),
                            y: .value("Particle", 40.0)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(.black.opacity(0.33))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                    AreaMark(
                        x: .value("Date", Date.round(from: measurement.timestamp, strategy: .previousHour) ?? Date.now),
                        yStart: .value("Particle", viewModel.range[selector]?.lowerBound ?? 0.0),
                        yEnd: .value("Particle", measurement.value.value)
                    )
                    .interpolationMethod(.catmullRom(alpha: 0.33))
                    .foregroundStyle(Gradient.linear)
                }

                if let current = viewModel.current[selector] {
                    RuleMark(x: .value("Date", current.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", current.timestamp),
                        y: .value("Particle", current.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(current.timestamp.absoluteString())
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.0f%@", current.value.value, current.value.unit.symbol))
                                if let icon = viewModel.trend[selector] {
                                    Image(systemName: icon)
                                }
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .quality(current.quality)
                    }
                }

                if let timestamp = self.timestamp {
                    if let value = viewModel.measurements[selector]?.first(where: { $0.timestamp == timestamp }) {
                        RuleMark(x: .value("Date", Date.round(from: timestamp, strategy: self.rounding) ?? Date.now))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                        PointMark(
                            x: .value("Date", timestamp),
                            y: .value("Particle", value.value.value)
                        )
                        .symbolSize(CGSize(width: 7, height: 7))
                        .annotation(position: .bottomTrailing, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                            VStack {
                                Text(timestamp.absoluteString())
                                    .font(.footnote)
                                HStack {
                                    Text(String(format: "%.0f%@", value.value.value, value.value.unit.symbol))
                                        .font(.headline)
                                }
                            }
                            .padding(7)
                            .padding(.horizontal, 7)
                            .quality(value.quality)
                        }
                    }
                }
            }
            .chartYScale(domain: viewModel.range[selector] ?? 0.0 ... 0.0)
            .chartOverlay { geometryProxy in
                GeometryReader { geometryReader in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let horizontalAmount = abs(value.translation.width)
                                    let verticalAmount = abs(value.translation.height)
                                    if horizontalAmount > verticalAmount * 2.0 {
                                        if let plotFrame = geometryProxy.plotFrame {
                                            let x = value.location.x - geometryReader[plotFrame].origin.x
                                            if let source: Date = geometryProxy.value(atX: x) {
                                                if let target = Date.round(from: source, strategy: self.rounding) {
                                                    self.timestamp = target
                                                }
                                            }
                                        }
                                    }
                                }
                                .onEnded { value in
                                    self.timestamp = nil
                                }
                        )
                }
            }
        }
    }
}

struct ParticleView: View {
    @Environment(ParticleViewModel.self) private var presenter

    enum ParticleSymbol: String, CaseIterable {
        case pm10 = "\u{1D40F}\u{1D40C}\u{2081}\u{2080}"  // PM10, Particulate matter < 10µm
        case co = "\u{1D402}\u{1D40E}"  // CO, Carbon monoxide
        case o3 = "\u{1D40E}\u{2083}"  // O3, Ozone
        case so2 = "\u{1D412}\u{1D40E}\u{2082}"  // SO2, Sulfur dioxide
        case no2 = "\u{1D40D}\u{1D40E}\u{2082}"  // NO2, Nitrogen dioxide
        case lead = "\u{1D40F}\u{1D41B}"  // Pb, Lead in particulate matter < 10µm
        case benzoapyrene = "\u{1D402}\u{2082}\u{2080}\u{1D407}\u{2081}\u{2082}"  // C20H12, Benzo(a)pyrene in particulate matter < 10µm
        case benzene = "\u{1D402}\u{2086}\u{1D407}\u{2086}"  // C6H6, Benzene
        case pm25 = "\u{1D40F}\u{1D40C}\u{2082}\u{2085}"  // Particulate matter < 2.5µm
        case arsenic = "\u{1D400}\u{1D42C}"  // As, Arsenic in particulate matter < 10µm
        case cadmium = "\u{1D402}\u{1D41D}"  // Cd, Cadmium in particulate matter < 10µm
        case nickel = "\u{1D40D}\u{1D422}"  // Ni, Nickel in particulate matter < 10µm
    }

    private let symbols: [ProcessSelector: ParticleSymbol] = [
        .particle(.pm10): .pm10,
        .particle(.pm25): .pm25,
        .particle(.o3): .o3,
        .particle(.no2): .no2,
        .particle(.co): .co,
        .particle(.so2): .so2,
        .particle(.lead): .lead,
        .particle(.benzoapyrene): .benzoapyrene,
        .particle(.benzene): .benzene,
        .particle(.arsenic): .arsenic,
        .particle(.cadmium): .cadmium,
        .particle(.nickel): .nickel
    ]

    var body: some View {
        VStack {
            if self.presenter.sensor?.timestamp == nil {
                ActivityIndicator()
            }
            else {
                HStack(alignment: .bottom) {
                    HStack {
                        Image(systemName: "safari")
                        Text(String(format: "%@", self.presenter.sensor?.placemark ?? "<Unknown>"))
                    }
                    Spacer()
                    Text("Last update: \(Date.absoluteString(date: self.presenter.sensor?.timestamp))")
                        .foregroundColor(.gray)
                }
                .font(.footnote)

                ForEach(ProcessSelector.Particle.allCases, id: \.self) { selector in
                    if self.presenter.isAvailable(selector: .particle(selector)) {
                        VStack {
                            HStack(alignment: .bottom) {
                                Text("\((symbols[.particle(selector)] ?? .pm10).rawValue)")
                                Spacer()
                            }
                            ParticleChart(selector: .particle(selector), rounding: .previousHour)
                        }
                        .padding(.vertical, 5)
                        .frame(height: 167)
                    }
                }
            }
        }
        .padding(5)
        .padding(.trailing)
        .cornerRadius(13)
    }
}
