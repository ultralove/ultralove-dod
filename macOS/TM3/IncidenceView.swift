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
            HStack(alignment: .bottom) {
                Text(String(format: "COVID-19 Incidence in %@:", viewModel.sensor?.id ?? "<Unknown>"))
                Spacer()
                HStack {
                    Image(systemName: "globe")
                    Text(String(format: "%@", viewModel.sensor?.placemark ?? "<Unknown>"))
                        .foregroundColor(.blue)
                        .underline()
                        .onTapGesture {
                        }
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                }
                .font(.footnote)
            }
            if viewModel.sensor?.timestamp == nil {
                ActivityIndicator()
            }
            else {
                _view()
            }
            HStack {
                Text("Last update: \(Date.absoluteString(date: viewModel.sensor?.timestamp))")
                    .font(.footnote)
                Spacer()
            }
        }
    }

    func _view() -> some View {
        VStack {
            Chart {
                ForEach(viewModel.incidence) { incidence in
                    LineMark(
                        x: .value("Date", incidence.timestamp),
                        y: .value("Incidence", incidence.value.value)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(.gray.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", incidence.timestamp),
                        y: .value("Incidence", incidence.value.value)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(Gradient.linear)
                }

                if let currentIncidence = viewModel.incidence.first(where: { $0.timestamp == Date.roundToLastDayChange(from: Date.now) }) {
                    RuleMark(x: .value("Date", currentIncidence.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentIncidence.timestamp),
                        y: .value("Incidence", currentIncidence.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@", currentIncidence.timestamp.dateString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f", currentIncidence.value.value))
                                Image(systemName: viewModel.trend)
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .qualityCode(qualityCode: currentIncidence.quality)
                    }
                }
                if let selectedDate, let selectedIncidence = viewModel.incidence.first(where: { $0.timestamp == selectedDate }) {
                    RuleMark(x: .value("Date", selectedDate))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Incidence", selectedIncidence.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@", selectedDate.dateString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f", selectedIncidence.value.value))
                                    .font(.headline)
                            }
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .qualityCode(qualityCode: selectedIncidence.quality)
                    }
                }
            }
            .chartYScale(domain: 0 ... viewModel.maxIncidence.value)
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
        }
    }
}
