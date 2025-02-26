import Charts
import SwiftUI

struct ForecastView: View {
    @Environment(ForecastViewModel.self) private var viewModel
    @State private var selectedDate: Date?
    let header: String
    let selector: ForecastSelector

    var body: some View {
        VStack {
            if viewModel.timestamp == nil {
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
                    AreaMark(
                        x: .value("Date", Date.roundToPreviousHour(from: measurement.timestamp) ?? Date.now),
                        yStart: .value("Forecast", viewModel.minValue(selector: selector).value),
                        yEnd: .value("Forecast", measurement.value.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Gradient.linear)
                }

                if let current = viewModel.current(selector: selector) {
                    RuleMark(x: .value("Date", current.timestamp))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", current.timestamp),
                        y: .value("Forecast", current.value.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topTrailing, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                        VStack {
                            Text(String(format: "%@ %@", current.timestamp.dateString(), current.timestamp.timeString()))
                                .font(.footnote)
                            HStack {
                                //                                    Image(systemName: currentTemperature.symbol)
                                Text(String(format: "%.1f%@", current.value.value, current.value.unit.symbol))
                                Image(systemName: viewModel.trend(selector: selector))
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .quality(current.quality)
                    }
                }

                if let selectedDate {
                    if let selectedValue = viewModel.measurements[selector]?.first(where: { $0.timestamp == selectedDate }) {
                        RuleMark(x: .value("Date", Date.roundToPreviousHour(from: selectedDate) ?? Date.now))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                        PointMark(
                            x: .value("Date", selectedDate),
                            y: .value("Forecast", selectedValue.value.value)
                        )
                        .symbolSize(CGSize(width: 7, height: 7))
                        .annotation(position: .bottomTrailing, spacing: 0, overflowResolution: .init(x: .fit, y: .fit)) {
                            VStack {
                                Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                    .font(.footnote)
                                HStack {
                                    //                                    Image(systemName: selectedTemperature.symbol)
                                    Text(String(format: "%.1f%@", selectedValue.value.value, selectedValue.value.unit.symbol))
                                        .font(.headline)
                                }
                            }
                            .padding(7)
                            .padding(.horizontal, 7)
                            .quality(selectedValue.quality)
                        }
                    }
                }
            }
            .chartYScale(domain: viewModel.minValue(selector: selector).value ... viewModel.maxValue(selector: selector).value)
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
                                                if let target = Date.roundToPreviousHour(from: source) {
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
