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
                ForEach(viewModel.level) { level in
                    LineMark(
                        x: .value("Date", level.date),
                        y: .value("Level", level.value)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(.gray.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", level.date),
                        y: .value("Level", level.value)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(linearGradient)
                }

                if let currentLevel = viewModel.level.first(where: { $0.date == Date.roundToPreviousQuarterHour(from: Date.now) }) {
                    RuleMark(x: .value("Date", currentLevel.date))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentLevel.date),
                        y: .value("Lavel", currentLevel.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", currentLevel.date.dateString(), currentLevel.date.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f", currentLevel.value))
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
                if let selectedDate, let selectedLevel = viewModel.level.first(where: { $0.date == selectedDate })?.value {
                    RuleMark(x: .value("Date", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Incidence", selectedLevel)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                .font(.footnote)
                        HStack {
                                Text(String(format: "%.1f", selectedLevel))
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
