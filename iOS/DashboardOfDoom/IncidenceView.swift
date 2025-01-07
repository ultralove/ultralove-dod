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
                Text(String(format: "COVID-19 Incidence forecast for %@:", viewModel.station ?? "<Unknown>"))
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

                if let currentIncidence = viewModel.incidence.first(where: { $0.date == Date.roundToLastDayChange(from: Date.now) }) {
                    RuleMark(x: .value("Date", currentIncidence.date))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentIncidence.date),
                        y: .value("Incidence", currentIncidence.incidence)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@", currentIncidence.date.dateString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f", currentIncidence.incidence))
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
                if let selectedDate, let selectedIncidence = viewModel.incidence.first(where: { $0.date == selectedDate })?.incidence {
                    RuleMark(x: .value("Date", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Incidence", selectedIncidence)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@", selectedDate.dateString()))
                                .font(.footnote)
                        HStack {
                                Text(String(format: "%.1f", selectedIncidence))
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
            .chartYScale(domain: 0 ... viewModel.maxIncidence)
            .chartOverlay { geometryProxy in
                GeometryReader { geometryReader in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let plotFrame = geometryProxy.plotFrame {
                                    let x = value.location.x - geometryReader[plotFrame].origin.x
                                    if let source: Date = geometryProxy.value(atX: x) {
                                        if let target = Date.roundToLastDayChange(from: source) {
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
