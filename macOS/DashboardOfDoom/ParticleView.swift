import Charts
import SwiftUI

struct ParticleView: View {
    @Environment(ParticleViewModel.self) private var viewModel
    @State private var selectedDate: Date?
    let selector: ParticleSelector

    private let symbols: [ParticleSelector: ParticleSymbol] = [
        .pm10: .pm10,
        .pm25: .pm25,
        .o3: .o3,
        .no2: .no2,
        .co: .co,
        .so2: .so2,
        .lead: .lead,
        .benzoapyrene: .benzoapyrene,
        .benzene: .benzene,
        .arsenic: .arsenic,
        .cadmium: .cadmium,
        .nickel: .nickel
    ]

    var body: some View {
        if viewModel.hasMeasurements(selector: selector) {
        VStack {
            if viewModel.timestamp == nil {
                ActivityIndicator()
            }
            else {
                    HeaderView(label: "\((symbols[selector] ?? .pm10).rawValue) at", sensor: viewModel.sensor)
                _view()
                FooterView(sensor: viewModel.sensor)
            }
        }
        .padding()
        .cornerRadius(13)
    }
    }

    func _view() -> some View {
        VStack {
            Chart {
                ForEach(viewModel.measurements[selector] ?? []) { measurement in
                    if selector == .pm10 {
                        LineMark(
                            x: .value("Date", measurement.timestamp),
                            y: .value("Particle", 40.0)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(.black.opacity(0.33))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                    else if selector == .pm25 {
                        LineMark(
                            x: .value("Date", measurement.timestamp),
                            y: .value("Particle", 25.0)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(.black.opacity(0.33))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                    else if selector == .no2 {
                        LineMark(
                            x: .value("Date", measurement.timestamp),
                            y: .value("Particle", 40.0)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(.black.opacity(0.33))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                    AreaMark(
                        x: .value("Date", Date.roundToPreviousHour(from: measurement.timestamp) ?? Date.now),
                        yStart: .value("Particle", viewModel.minValue(selector: selector).value),
                        yEnd: .value("Particle", measurement.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Gradient.linear)
                }

                if let current = viewModel.current(selector: selector) {
                    RuleMark(x: .value("Date", current.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", current.timestamp),
                        y: .value("Particle", current.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", current.timestamp.dateString(), current.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.0f%@", current.value.value, current.value.unit.symbol))
                                Image(systemName: viewModel.trend(selector: selector))
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .quality(current.quality)
                    }
                }

                if let selectedDate {
                    if let selectedValue = viewModel.measurements[selector]?.first(where: { $0.timestamp == selectedDate }) {
                        RuleMark(x: .value("Date", Date.roundToPreviousHour(from: selectedDate) ?? Date.now))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                        PointMark(
                            x: .value("Date", selectedDate),
                            y: .value("Particle", selectedValue.value.value)
                        )
                        .symbolSize(CGSize(width: 7, height: 7))
                        .annotation(position: .bottomTrailing, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                            VStack {
                                Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                    .font(.footnote)
                                HStack {
                                    Text(String(format: "%.0f%@", selectedValue.value.value, selectedValue.value.unit.symbol))
                                        .font(.headline)
                                }
                            }
                            .padding(7)
                            .padding(.horizontal, 7)
                            .quality(selectedValue.quality)
                        }
                    }
                }
            }
            .chartYScale(domain: viewModel.minValue(selector: selector).value ... viewModel.maxValue(selector: selector).value)
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
                                                if let target = Date.roundToPreviousHour(from: source) {
                                                    self.selectedDate = target
                                                }
                                            }
                                        }
                                    }
                                }
                                .onEnded { value in
                                    self.selectedDate = nil
                                }
                        )
                }
            }
        }
    }
}
