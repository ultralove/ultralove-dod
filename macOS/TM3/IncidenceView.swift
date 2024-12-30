import Charts
import SwiftUI

struct IncidenceView: View {
    @Environment(IncidenceViewModel.self) private var viewModel
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
                Text(String(format: "COVID-19 Incidence forecast for %@:", viewModel.location?.name ?? "<Unknown>"))
                    .font(.headline)
                Spacer()
            }
            Chart {
                ForEach(viewModel.incidence) { incidence in
                    LineMark(
                        x: .value("Date", incidence.date),
                        y: .value("Incidence", incidence.incidence)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(.gray.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", incidence.date),
                        y: .value("Incidence", incidence.incidence)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(linearGradient)
                }

                if let currentIncidence = viewModel.incidence.first(where: { $0.date == IncidenceViewModel.nearestDataPoint(from: Date.now) }) {
                    RuleMark(x: .value("Date", currentIncidence.date))
                        .symbolSize(CGSize(width: 3, height: 3))
                    PointMark(
                        x: .value("Date", currentIncidence.date),
                        y: .value("Incidence", currentIncidence.incidence)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0) {
                        HStack {
                            Text(String(format: "%@ %.1f", currentIncidence.date.dateString(), currentIncidence.incidence))
                            Image(systemName: viewModel.trendSymbol)
                        }
                        .font(.headline)
                    }
                }

                if let selectedDate, let selectedIncidence = viewModel.incidence.first(where: { $0.date == selectedDate })?.incidence {
                    RuleMark(x: .value("Date", selectedDate))
                        .symbolSize(CGSize(width: 3, height: 3))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Incidence", selectedIncidence)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomLeading, spacing: 0) {
                        HStack {
                            Text(String(format: "%@ %.1f", selectedDate.dateString(), selectedIncidence))
                        }
                        .font(.headline)
                    }
                }
            }
            .chartOverlay { geometryProxy in
                GeometryReader { geometryReader in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if let plotFrame = geometryProxy.plotFrame {
                                        let x = value.location.x - geometryReader[plotFrame].origin.x
                                        if let source: Date = geometryProxy.value(atX: x) {
                                            if let target = IncidenceViewModel.nearestDataPoint(from: source) {
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

