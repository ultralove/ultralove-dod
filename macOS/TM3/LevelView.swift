import Charts
import SwiftUI

struct LevelView: View {
    @Environment(LevelViewModel.self) private var viewModel
    @State private var selectedDate: Date?

    private let linearGradient = LinearGradient(
        gradient: Gradient(colors: [Color.blue.opacity(0.66), Color.blue.opacity(0.0)]),
        startPoint: .top,
        endPoint: .bottom)

    var body: some View {
        VStack {
            if viewModel.timestamp == nil {
                ActivityIndicator()
            }
            else {
                _view()
            }
        }
    }

    func _view() -> some View {
        VStack {
            HStack {
                Text(String(format: "Level at station %@:", viewModel.station ?? "<Unknown>"))
                Spacer()
            }
            Chart {
                ForEach(viewModel.measurements) { level in
                    LineMark(
                        x: .value("Date", level.timestamp),
                        y: .value("Level", level.measurement.value)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(.gray.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", level.timestamp),
                        y: .value("Level", level.measurement.value)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(linearGradient)
                }

                if let currentLevel = viewModel.measurements.first(where: { $0.timestamp == Date.roundToPreviousQuarterHour(from: Date.now) }) {
                    RuleMark(x: .value("Date", currentLevel.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentLevel.timestamp),
                        y: .value("Level", currentLevel.measurement.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", currentLevel.timestamp.dateString(), currentLevel.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.2f%@", currentLevel.measurement.value, currentLevel.measurement.unit.symbol))
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

                if let selectedDate, let selectedLevel = viewModel.measurements.first(where: { $0.timestamp == selectedDate }) {
                    RuleMark(x: .value("Date", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Level", selectedLevel.measurement.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.2f%@", selectedLevel.measurement.value, selectedLevel.measurement.unit.symbol))
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
            .chartYScale(domain: 0 ... (viewModel.maxLevel + 10))
            .chartOverlay { geometryProxy in
                GeometryReader { geometryReader in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let plotFrame = geometryProxy.plotFrame {
                                    let x = value.location.x - geometryReader[plotFrame].origin.x
                                    if let source: Date = geometryProxy.value(atX: x) {
                                        if let target = Date.roundToPreviousQuarterHour(from: source) {
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
                Text("Last update: \(Date.absoluteString(date: viewModel.timestamp))")
                    .font(.footnote)
                Spacer()
            }
        }
    }
}
