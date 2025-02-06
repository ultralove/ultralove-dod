import Charts
import SwiftUI

struct ForecastView: View {
    @Environment(ForecastViewModel.self) private var viewModel
    @State private var selectedDate: Date?
    let header: String
    let type: MeasurementType

    enum MeasurementType {
        case actual
        case apparent
    }

    private func selectValue(_ type: MeasurementType, from forecast: Forecast) -> Double {
        switch type {
        case .actual:
            return forecast.temperature.value
        case .apparent:
            return forecast.apparentTemperature.value
        }
    }

    private func selectSymbol(_ type: MeasurementType, from forecast: Forecast) -> String {
        switch type {
        case .actual:
            return forecast.temperature.unit.symbol
        case .apparent:
            return forecast.apparentTemperature.unit.symbol
        }
    }

    var body: some View {
        VStack {
            HeaderView(label: header, sensor: viewModel.sensor)
            if viewModel.timestamp == nil {
                ActivityIndicator()
            }
            else {
                _view()
            }
            FooterView(sensor: viewModel.sensor)
        }
        .padding()
        .cornerRadius(13)
    }

    func _view() -> some View {
        VStack {
            Chart {
                ForEach(viewModel.measurements) { forecast in
                    LineMark(
                        x: .value("Date", Date.roundToPreviousHour(from: forecast.timestamp) ?? Date.now),
                        y: .value("Temperature", selectValue(type, from: forecast))
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", Date.roundToPreviousHour(from: forecast.timestamp) ?? Date.now),
                        yStart: .value("Temperature", viewModel.minValue.value),
                        yEnd: .value("Temperature", selectValue(type, from: forecast))
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Gradient.linear)
                }

                if let currentDate = Date.roundToNextHour(from: Date.now) {
                    if let currentTemperature = viewModel.measurements.first(where: { $0.timestamp == currentDate }) {
                        let value = selectValue(type, from: currentTemperature)
                        let symbol = selectSymbol(type, from: currentTemperature)
                        RuleMark(x: .value("Date", currentDate))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                        PointMark(
                            x: .value("Date", currentDate),
                            y: .value("Temperature", value)
                        )
                        .symbolSize(CGSize(width: 7, height: 7))
                        .annotation(position: .topTrailing, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                            VStack {
                                Text(String(format: "%@ %@", currentDate.dateString(), currentDate.timeString()))
                                    .font(.footnote)
                                HStack {
                                    Image(systemName: currentTemperature.symbol)
                                    Text(String(format: "%.1f%@", value, symbol))
                                    Image(systemName: viewModel.trend)
                                }
                                .font(.headline)
                            }
                            .padding(7)
                            .padding(.horizontal, 7)
                            .qualityCode(qualityCode: currentTemperature.quality)
                        }
                    }
                }

                if let selectedDate {
                    if let selectedTemperature = viewModel.measurements.first(where: { $0.timestamp == selectedDate }) {
                        let value = selectValue(type, from: selectedTemperature)
                        let symbol = selectSymbol(type, from: selectedTemperature)
                        RuleMark(x: .value("Date", Date.roundToPreviousHour(from: selectedDate) ?? Date.now))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                        PointMark(
                            x: .value("Date", selectedDate),
                            y: .value("Temperature", value)
                        )
                        .symbolSize(CGSize(width: 7, height: 7))
                        .annotation(position: .bottomTrailing, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                            VStack {
                                Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                    .font(.footnote)
                                HStack {
                                    Image(systemName: selectedTemperature.symbol)
                                    Text(String(format: "%.1f%@", value, symbol))
                                        .font(.headline)
                                }
                            }
                            .padding(7)
                            .padding(.horizontal, 7)
                            .qualityCode(qualityCode: selectedTemperature.quality)
                        }
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
