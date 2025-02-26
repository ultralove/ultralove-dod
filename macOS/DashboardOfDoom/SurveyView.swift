import Charts
import SwiftUI

struct SurveyView: View {
    @Environment(SurveyViewModel.self) private var viewModel
    @State private var selectedDate: Date?
    let header: String
    let selector: SurveySelector

    var body: some View {
        VStack {
            if viewModel.sensor?.timestamp == nil {
                ActivityIndicator()
            }
            else {
                HeaderView(label: header, sensor: viewModel.sensor)
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
                ForEach(viewModel.measurements[selector] ?? []) { measurement in
                    if selector != .fascists && selector != .clowns && selector != .sonstige {
                        LineMark(
                            x: .value("Date", measurement.timestamp),
                            y: .value("Survey", 5.0)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(.black.opacity(0.33))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                    AreaMark(
                        x: .value("Date", measurement.timestamp),
                        y: .value("Survey", measurement.value.value)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(viewModel.gradient(selector: selector))
                }

                if let currentValue = viewModel.current(selector: selector) {
                    RuleMark(x: .value("Date", currentValue.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentValue.timestamp),
                        y: .value("Survey", currentValue.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", currentValue.timestamp.dateString(), currentValue.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f%@", currentValue.value.value, currentValue.value.unit.symbol))
                                Image(systemName: viewModel.trend(selector: selector))
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .quality(currentValue.quality)
                    }
                }

                if let timestamp = selectedDate {
                    if let measurement = viewModel.measurements[selector]?.first(where: { $0.timestamp == selectedDate }) {
                        RuleMark(x: .value("Date", timestamp))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                        PointMark(
                            x: .value("Date", timestamp),
                            y: .value("Survey", measurement.value.value)
                        )
                        .symbolSize(CGSize(width: 7, height: 7))
                        .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                            VStack {
                                Text(String(format: "%@ %@", timestamp.dateString(), timestamp.timeString()))
                                    .font(.footnote)
                                HStack {
                                    Text(String(format: "%.1f%@", measurement.value.value, measurement.value.unit.symbol))
                                        .font(.headline)
                                }
                            }
                            .padding(7)
                            .padding(.horizontal, 7)
                            .quality(measurement.quality)
                        }
                    }
                }
            }
            .chartYScale(domain: viewModel.minValue.value ... viewModel.maxValue.value)
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
                                            if let target = Date.roundToLastUTCDayChange(from: source) {
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
