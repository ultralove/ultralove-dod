import Charts
import SwiftUI

struct SurveyView: View {
    @Environment(SurveyViewModel.self) private var viewModel
    @State private var timestamp: Date?
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
                            x: .value("Timestamp", measurement.timestamp),
                            y: .value("Value", 5.0)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(Color.treshold)
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                    AreaMark(
                        x: .value("Timestamp", measurement.timestamp),
                        y: .value("Value", measurement.value.value)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(viewModel.gradient(selector: selector))
                }

                if let measurement = viewModel.current(selector: selector) {
                    RuleMark(x: .value("Timestamp", measurement.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Timestamp", measurement.timestamp),
                        y: .value("Value", measurement.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", measurement.timestamp.dateString(), measurement.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f%@", measurement.value.value, measurement.value.unit.symbol))
                                Image(systemName: viewModel.trend(selector: selector))
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .quality(measurement.quality)
                    }
                }

                if let timestamp = timestamp {
                    if let measurement = viewModel.measurements[selector]?.first(where: { $0.timestamp == timestamp }) {
                        RuleMark(x: .value("Timestamp", timestamp))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                        PointMark(
                            x: .value("Timestamp", timestamp),
                            y: .value("Value", measurement.value.value)
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
                                            if let target = Date.round(from: source, strategy: .lastUTCDayChange) {
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
