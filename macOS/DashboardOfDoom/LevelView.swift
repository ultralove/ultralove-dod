import Charts
import SwiftUI

struct LevelView: View {
    @Environment(LevelViewModel.self) private var viewModel
    @State private var selectedDate: Date?

    var body: some View {
        VStack {
            if viewModel.sensor?.timestamp == nil {
                ActivityIndicator()
            }
            else {
                HeaderView(label: String(format: "Water Level of the", viewModel.sensor?.id ?? "<Unknown>"), sensor: viewModel.sensor)
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
                ForEach(viewModel.measurements) { level in
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

                if let currentLevel = viewModel.current {
                    RuleMark(x: .value("Date", currentLevel.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentLevel.timestamp),
                        y: .value("Level", currentLevel.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", currentLevel.timestamp.dateString(), currentLevel.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.2f%@", currentLevel.value.value, currentLevel.value.unit.symbol))
                                Image(systemName: viewModel.trend)
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .quality(currentLevel.quality)
                    }
                }

                if let selectedDate, let selectedLevel = viewModel.measurements.first(where: { $0.timestamp == selectedDate }) {
                    RuleMark(x: .value("Date", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Level", selectedLevel.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.2f%@", selectedLevel.value.value, selectedLevel.value.unit.symbol))
                                    .font(.headline)
                            }
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .quality(selectedLevel.quality)
                    }
                }
            }
            .chartYScale(domain: viewModel.minValue.value ... (viewModel.maxValue.value * 1.67))
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
                                                if let target = Date.roundToPreviousQuarterHour(from: source) {
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
