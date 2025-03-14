import Charts
import SwiftUI

struct RadiationChart: View {
    @Environment(RadiationViewModel.self) private var viewModel
    @State private var timestamp: Date?
    let selector: ProcessSelector
    let rounding: RoundingStrategy

    var body: some View {
        VStack {
            Chart {
                ForEach(viewModel.measurements[selector] ?? []) { radiation in
                    LineMark(
                        x: .value("Date", radiation.timestamp),
                        y: .value("Radiation", radiation.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.gray.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", radiation.timestamp),
                        y: .value("Radiation", radiation.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Gradient.linear)
                }

                if let current = viewModel.current[selector] {
                    RuleMark(x: .value("Date", current.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", current.timestamp),
                        y: .value("Radiation", current.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", current.timestamp.dateString(), current.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.3f%@", current.value.value, current.value.unit.symbol))
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
                    RuleMark(x: .value("Date", timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", timestamp),
                        y: .value("Radiation", value.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", timestamp.dateString(), timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.3f%@", value.value.value, value.value.unit.symbol))
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

struct RadiationView: View {
    @Environment(RadiationViewModel.self) private var viewModel
    let label: String
    let selector: ProcessSelector

    var body: some View {
        VStack {
            if viewModel.sensor?.timestamp == nil {
                ActivityIndicator()
            }
            else {
                ChartHeader(label: String(format: "Radiation", viewModel.sensor?.name ?? "<Unknown>"), sensor: viewModel.sensor)
                RadiationChart(selector: selector, rounding: .previousHour)
                ChartFooter(sensor: viewModel.sensor)
            }
        }
        .padding()
        .cornerRadius(13)
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
