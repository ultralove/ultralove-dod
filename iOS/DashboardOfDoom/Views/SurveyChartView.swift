import Charts
import SwiftUI

struct SurveyChartView: View {
    @Environment(SurveyPresenter.self) private var presenter
    @State private var timestamp: Date?
    let selector: ProcessSelector
    let rounding: RoundingStrategy

    private let labels: [ProcessSelector: String] = [
        .survey(.fascists): "Fascists",
        .survey(.clowns): "Clowns",
        .survey(.linke): "Die Linke",
        .survey(.gruene): "Die Grünen",
        .survey(.spd): "SPD",
        .survey(.afd): "AfD",
        .survey(.fdp): "FDP",
        .survey(.bsw): "BSW",
        .survey(.cducsu): "CDU/CSU"
    ]

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("\(self.labels[selector] ?? String(format: "%d <Unknown>", selector.rawValue))")
                Spacer()
            }
            Chart {
                ForEach(presenter.measurements[selector] ?? []) { measurement in
                    if selector != .survey(.fascists) && selector != .survey(.clowns) && selector != .survey(.sonstige) {
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
                    .foregroundStyle(presenter.gradient(selector: selector))
                }

                if let measurement = presenter.current[selector] {
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
                                if let icon = presenter.trend[selector] {
                                    Image(systemName: icon)
                                }
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .quality(measurement.quality)
                    }
                }

                if let timestamp = timestamp {
                    if let measurement = presenter.measurements[selector]?.first(where: { $0.timestamp == timestamp }) {
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
            .chartYScale(domain: presenter.range[selector] ?? 0.0 ... 0.0)
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
