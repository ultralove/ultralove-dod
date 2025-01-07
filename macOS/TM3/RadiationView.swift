import Charts
import SwiftUI

struct RadiationView: View {
    @Environment(RadiationViewModel.self) private var viewModel
    @State private var selectedDate: Date?

    private let linearGradient = LinearGradient(
        gradient: Gradient(colors: [Color.blue.opacity(0.66), Color.blue.opacity(0.0)]),
        startPoint: .top,
        endPoint: .bottom)

    var body: some View {
        if viewModel.timestamp == nil {
            ActivityIndicator()
        }
        else {
            _view()
        }
    }

    func _view() -> some View {
        VStack {
            HStack {
                Text(String(format: "Radiation at station %@:", viewModel.station ?? "<Unknown>"))
                Spacer()
            }
            Chart {
                ForEach(viewModel.measurements) { measurement in
                    LineMark(
                        x: .value("Date", measurement.timestamp),
                        y: .value("Radiation", measurement.total.value)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(.gray.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", measurement.timestamp),
                        y: .value("Radiation", measurement.total.value))
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(linearGradient)
                }

                if let currentRadiation = viewModel.measurements.first(where: { $0.timestamp == Date.roundToPreviousHour(from: Date.now) }) {
                    RuleMark(x: .value("Date", currentRadiation.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentRadiation.timestamp),
                        y: .value("Radiation", currentRadiation.total.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", currentRadiation.timestamp.dateString(), currentRadiation.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.3f%@", currentRadiation.total.value, currentRadiation.total.unit.symbol))
                                Image(systemName: viewModel.trendSymbol)
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .opacity(0.125)
                        )
                        .foregroundStyle(.black)
                    }
                }

                if let selectedDate, let selectedRadiation = viewModel.measurements.first(where: { $0.timestamp == selectedDate }) {
                    RuleMark(x: .value("Date", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Radiation", selectedRadiation.total.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.3f%@", selectedRadiation.total.value, selectedRadiation.total.unit.symbol))
                                    .font(.headline)
                            }
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .opacity(0.125)
                        )
                        .foregroundStyle(.black)
                    }
                }
            }
            .chartYScale(domain: 0 ... (viewModel.maxRadiation + 0.25))
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
            HStack {
                Text("Last update: \(Date.absoluteString(date: viewModel.timestamp ?? Date.now))")
                    .font(.footnote)
                Spacer()
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
