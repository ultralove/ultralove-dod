import Charts
import SwiftUI

struct IncidenceView: View {
    @Environment(IncidenceViewModel.self) private var viewModel
    @State private var selectedDate: Date?

    var body: some View {
        VStack {
            if viewModel.sensor?.timestamp == nil {
                ActivityIndicator()
            }
            else {
                HeaderView(label: "COVID-19 Incidence in", sensor: viewModel.sensor)
                _view()
                FooterView(sensor: viewModel.sensor)
            }
        }
        .padding()
        .cornerRadius(13)
    }

    func _view() -> some View {
        VStack {
            Chart {
                ForEach(viewModel.measurements) { incidence in
                    LineMark(
                        x: .value("Date", incidence.timestamp),
                        y: .value("Incidence", incidence.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.gray.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", incidence.timestamp),
                        y: .value("Incidence", incidence.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Gradient.linear)
                }

                if let currentIncidence = viewModel.current {
                    RuleMark(x: .value("Date", currentIncidence.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentIncidence.timestamp),
                        y: .value("Incidence", currentIncidence.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", currentIncidence.timestamp.dateString(), currentIncidence.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f", currentIncidence.value.value))
                                Image(systemName: viewModel.trend)
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .quality(currentIncidence.quality)
                    }
                }
                if let selectedDate, let selectedIncidence = viewModel.measurements.first(where: { $0.timestamp == selectedDate }) {
                    RuleMark(x: .value("Date", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Incidence", selectedIncidence.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f", selectedIncidence.value.value))
                                    .font(.headline)
                            }
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .quality(selectedIncidence.quality)
                    }
                }
            }
            .chartYScale(domain: viewModel.minValue.value ... viewModel.maxValue.value * 1.33)
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
                                                if let target = Date.roundToLastDayChange(from: source) {
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
