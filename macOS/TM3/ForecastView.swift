import Charts
import SwiftUI

struct ForecastView: View {
    @Environment(ForecastViewModel.self) private var viewModel
    @State private var selectedDate: Date?

    var body: some View {
        VStack {
            HeaderView(label: "Temperature (actual) forecast for", sensor: viewModel.sensor)
            if viewModel.timestamp == nil {
                ActivityIndicator()
            }
            else {
                _view()
            }
            FooterView(sensor: viewModel.sensor)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(13)
    }

    func _view() -> some View {
        VStack {
            Chart {
                ForEach(viewModel.measurements) { forecast in
                    LineMark(
                        x: .value("Date", Date.roundToPreviousHour(from: forecast.timestamp) ?? Date.now),
                        y: .value("Temperature", forecast.temperature.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", Date.roundToPreviousHour(from: forecast.timestamp) ?? Date.now),
                        yStart: .value("Temperature", viewModel.minValue.value),
                        yEnd: .value("Temperature", forecast.temperature.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Gradient.linearBlue)
                }

                if let currentDate = Date.roundToNextHour(from: Date.now),
                    let currentTemperature = viewModel.measurements.first(where: { $0.timestamp == currentDate })
                {
                    RuleMark(x: .value("Date", currentDate))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentDate),
                        y: .value("Temperature", currentTemperature.temperature.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topTrailing, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", currentDate.dateString(), currentDate.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f%@", currentTemperature.temperature.value, currentTemperature.temperature.unit.symbol))
                                Image(systemName: viewModel.trend)
                            }
                            .font(.headline)
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .qualityCode(qualityCode: currentTemperature.quality)
                    }
                }
                if let selectedDate, let selectedTemperature = viewModel.measurements.first(where: { $0.timestamp == selectedDate }) {
                    RuleMark(x: .value("Date", Date.roundToPreviousHour(from: selectedDate) ?? Date.now))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Temperature", selectedTemperature.temperature.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomTrailing, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f%@", selectedTemperature.temperature.value, selectedTemperature.temperature.unit.symbol))
                                    .font(.headline)
                            }
                        }
                        .padding(7)
                        .padding(.horizontal, 7)
                        .qualityCode(qualityCode: selectedTemperature.quality)
                    }
                }
            }
            .chartYScale(domain: viewModel.minValue.value ... viewModel.maxValue.value)
            .chartOverlay { geometryProxy in
                GeometryReader { geometryReader in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let plotFrame = geometryProxy.plotFrame {
                                    let x = value.location.x - geometryReader[plotFrame].origin.x
                                    if let date: Date = geometryProxy.value(atX: x), let roundedHour = Date.roundToPreviousHour(from: date) {
                                        self.selectedDate = roundedHour
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
