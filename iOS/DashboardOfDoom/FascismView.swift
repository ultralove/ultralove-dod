import Charts
import SwiftUI

struct FascismView: View {
    @Environment(FascismViewModel.self) private var viewModel
    @State private var selectedDate: Date?

    var body: some View {
        VStack {
            HeaderView(label: "Fascist vote share in", sensor: viewModel.sensor)
            if viewModel.sensor?.timestamp == nil {
                ActivityIndicator()
            }
            else {
                _view()
            }
            FooterView(sensor: viewModel.sensor)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(13)
    }

    func _view() -> some View {
        VStack {
            Chart {
                ForEach(viewModel.measurements) { measurement in
                    LineMark(
                        x: .value("Date", measurement.timestamp),
                        y: .value("Fascism", measurement.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.gray.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", measurement.timestamp),
                        y: .value("Fascism", measurement.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Gradient.fascist)
                }

                if let currentValue = viewModel.current {
                    RuleMark(x: .value("Date", currentValue.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentValue.timestamp),
                        y: .value("Fascism", currentValue.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", currentValue.timestamp.dateString(), currentValue.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.0f%@", currentValue.value.value, currentValue.value.unit.symbol))
                                Image(systemName: viewModel.trend)
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .qualityCode(qualityCode: currentValue.quality)
                    }
                }

                if let selectedDate, let selectedValue = viewModel.measurements.first(where: { $0.timestamp == selectedDate }) {
                    RuleMark(x: .value("Date", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Fascism", selectedValue.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
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
                        .qualityCode(qualityCode: selectedValue.quality)
                    }
                }
            }
            .chartYScale(domain: viewModel.minValue.value ... viewModel.maxValue.value)
            .chartOverlay { geometryProxy in
                GeometryReader { geometryReader in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if let plotFrame = geometryProxy.plotFrame {
                                        let x = value.location.x - geometryReader[plotFrame].origin.x
                                        if let source: Date = geometryProxy.value(atX: x) {
                                            if let target = Date.roundToLastUTCDayChange(from: source) {
                                                self.selectedDate = target
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

