import Charts
import SwiftUI

struct LevelChart: View {
    @Environment(LevelViewModel.self) private var viewModel
    @State private var timestamp: Date?
    let selector: ProcessSelector
    let rounding: RoundingStrategy

    var body: some View {
        VStack {
            Chart {
                ForEach(viewModel.measurements[selector] ?? []) { level in
                    LineMark(
                        x: .value("Date", level.timestamp),
                        y: .value("Level", level.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.gray.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", level.timestamp),
                        y: .value("Level", level.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Gradient.linear)
                }

                if let current = viewModel.current[selector] {
                    RuleMark(x: .value("Date", current.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", current.timestamp),
                        y: .value("Level", current.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", current.timestamp.dateString(), current.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.2f%@", current.value.value, current.value.unit.symbol))
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
                            y: .value("Level", value.value.value)
                        )
                        .symbolSize(CGSize(width: 7, height: 7))
                        .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                            VStack {
                                Text(String(format: "%@ %@", timestamp.dateString(), timestamp.timeString()))
                                    .font(.footnote)
                                HStack {
                                    Text(String(format: "%.2f%@", value.value.value, value.value.unit.symbol))
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

struct LevelView: View {
    @Environment(LevelViewModel.self) private var viewModel
    let label: String
    let selector: ProcessSelector

    var body: some View {
        VStack {
            if viewModel.sensor?.timestamp == nil {
                ActivityIndicator()
            }
            else {
                ChartHeader(label: String(format: "Water Level", viewModel.sensor?.name ?? "<Unknown>"), sensor: viewModel.sensor)
                LevelChart(selector: selector, rounding: .previousQuarterHour)
                ChartFooter(sensor: viewModel.sensor)
            }
        }
        .padding()
        .cornerRadius(13)
    }
}
