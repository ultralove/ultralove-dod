import Charts
import SwiftUI

struct RadiationView: View {
    @Environment(RadiationViewModel.self) private var viewModel
    @State private var selectedDate: Date?

    var body: some View {
        VStack {
            HeaderView(label: "Radiation in", sensor: viewModel.sensor)
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
                        y: .value("Radiation", measurement.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.gray.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", measurement.timestamp),
                        y: .value("Radiation", measurement.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Gradient.linearBlue)
                }

                if let currentRadiation = viewModel.current {
                    RuleMark(x: .value("Date", currentRadiation.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentRadiation.timestamp),
                        y: .value("Radiation", currentRadiation.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", currentRadiation.timestamp.dateString(), currentRadiation.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.3f%@", currentRadiation.value.value, currentRadiation.value.unit.symbol))
                                Image(systemName: viewModel.trend)
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .qualityCode(qualityCode: currentRadiation.quality)
                    }
                }

                if let selectedDate, let selectedRadiation = viewModel.measurements.first(where: { $0.timestamp == selectedDate }) {
                    RuleMark(x: .value("Date", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Radiation", selectedRadiation.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.3f%@", selectedRadiation.value.value, selectedRadiation.value.unit.symbol))
                                    .font(.headline)
                            }
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .qualityCode(qualityCode: selectedRadiation.quality)
                    }
                }
            }
            .chartYScale(domain: viewModel.minValue.value ... (viewModel.maxValue.value * 1.67))
            .chartOverlay { geometryProxy in
                GeometryReader { geometryReader in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if let plotFrame = geometryProxy.plotFrame {
                                        let x = value.location.x - geometryReader[plotFrame].origin.x
                                        if let source: Date = geometryProxy.value(atX: x) {
                                            if let target = Date.roundToPreviousHour(from: source) {
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

//Chart {
//    BarMark(x: .value("Total", "Total"), y: .value("Radiation", viewModel.radiation?.total.value ?? Double.nan))
//        .foregroundStyle(linearGradient)
//        .annotation {
//            Text(String(format: "%.3f%@", viewModel.radiation?.total.value ?? Double.nan, viewModel.radiation?.total.unit.symbol ?? ""))
//                .font(.headline)
//        }
//        .alignsMarkStylesWithPlotArea()
//
//    BarMark(x: .value("Cosmic", "Cosmic"), y: .value("Radiation", viewModel.radiation?.cosmic?.value ?? Double.nan))
//        .foregroundStyle(linearGradient)
//        .annotation {
//            Text(String(format: "%.3f%@", viewModel.radiation?.cosmic?.value ?? Double.nan, viewModel.radiation?.cosmic?.unit.symbol ?? ""))
//                .font(.headline)
//        }
//        .alignsMarkStylesWithPlotArea()
//    BarMark(x: .value("Terrestrial", "Terrestrial"), y: .value("Radiation", viewModel.radiation?.terrestrial?.value ?? Double.nan))
//        .foregroundStyle(linearGradient)
//        .annotation {
//            Text(String(format: "%.3f%@", viewModel.radiation?.terrestrial?.value ?? Double.nan, viewModel.radiation?.terrestrial?.unit.symbol ?? ""))
//                .font(.headline)
//        }
//        .alignsMarkStylesWithPlotArea()
//}
