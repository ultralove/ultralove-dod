import Charts
import SwiftUI

struct CovidChart: View {
    @Environment(CovidViewModel.self) private var viewModel
    @State private var timestamp: Date?
    let selector: ProcessSelector
    let rounding: RoundingStrategy

    var body: some View {
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

                if let current = viewModel.current[selector] {
                    RuleMark(x: .value("Date", current.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", current.timestamp),
                        y: .value("Incidence", current.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(current.timestamp.absoluteString())
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f%@", current.value.value, current.value.unit.symbol))
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
                            y: .value("Incidence", value.value.value)
                        )
                        .symbolSize(CGSize(width: 7, height: 7))
                        .annotation(position: .bottomLeading, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                            VStack {
                                Text(timestamp.absoluteString())
                                    .font(.footnote)
                                HStack {
                                    Text(String(format: "%.1f%@", value.value.value, value.value.unit.symbol))
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

struct CovidView: View {
    @Environment(CovidViewModel.self) private var presenter

    private let labels: [ProcessSelector: String] = [
        .covid(.incidence): "Weekly Incidence",
        .covid(.cases): "Cases",
        .covid(.deaths): "Deaths",
        .covid(.recovered): "Recovered"
    ]

    var body: some View {
        VStack {
            if self.presenter.sensor?.timestamp == nil {
                ActivityIndicator()
            }
            else {
                HStack(alignment: .bottom) {
                    HStack {
                        Image(systemName: "safari")
                        Text(String(format: "%@", self.presenter.sensor?.placemark ?? "<Unknown>"))
                    }
                    Spacer()
                    Text("Last update: \(Date.absoluteString(date: self.presenter.sensor?.timestamp))")
                        .foregroundColor(.gray)
                }
                .font(.footnote)

                ForEach(ProcessSelector.Covid.allCases, id: \.self) { selector in
                    if self.presenter.isAvailable(selector: .covid(selector)) {
                        VStack {
                            HStack(alignment: .bottom) {
                                Text("\(self.presenter.sensor?.name ?? "<Unknown>") \(self.labels[.covid(selector)] ?? "<Unknown>")")
                                Spacer()
                            }
                            CovidChart(selector: .covid(selector), rounding: .lastDayChange)
                        }
                        .padding(.vertical, 5)
                        .frame(height: 167)
                    }
                }
            }
        }
        .padding(5)
        .padding(.trailing)
        .cornerRadius(13)
    }
}
