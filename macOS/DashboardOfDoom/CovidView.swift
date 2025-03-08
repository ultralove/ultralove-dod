import Charts
import SwiftUI

struct CovidView: View {
    @Environment(CovidViewModel.self) private var viewModel
    @State private var selectedDate: Date?
    let label: String
    let selector: ProcessSelector

    var body: some View {
        VStack {
            if viewModel.sensor?.timestamp == nil {
                ActivityIndicator()
            }
            else {
                ChartHeader(label: label, sensor: viewModel.sensor)
                _view()
                ChartFooter(sensor: viewModel.sensor)
            }
        }
        .padding()
        .cornerRadius(13)
    }

    func _view() -> some View {
        VStack {
            Chart {
                ForEach(viewModel.measurements[selector] ?? []) { incidence in
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

                if let current = viewModel.current(selector: selector) {
                    RuleMark(x: .value("Date", current.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", current.timestamp),
                        y: .value("Incidence", current.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", current.timestamp.dateString(), current.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f%@", current.value.value, current.value.unit.symbol))
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
                        RuleMark(x: .value("Date", selectedDate))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                        PointMark(
                            x: .value("Date", selectedDate),
                            y: .value("Incidence", selectedValue.value.value)
                        )
                        .symbolSize(CGSize(width: 7, height: 7))
                        .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                            VStack {
                                Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                    .font(.footnote)
                                HStack {
                                    Text(String(format: "%.1f%@", selectedValue.value.value, selectedValue.value.unit.symbol))
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
            .chartYScale(domain: viewModel.minValue(selector: selector) ... viewModel.maxValue(selector: selector) * 1.33)
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
                                                if let target = Date.round(from: source, strategy: .lastDayChange) {
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
