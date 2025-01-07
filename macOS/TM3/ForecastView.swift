import Charts
import SwiftUI

struct ForecastView: View {
    @Environment(ForecastViewModel.self) private var viewModel
    @State private var selectedDate: Date?

    private let linearGradient = LinearGradient(
        gradient: Gradient(colors: [Color.blue.opacity(0.66), Color.blue.opacity(0.0)]),
        startPoint: .top,
        endPoint: .bottom)

    var body: some View {
        if viewModel.timestamp == nil {
            ActivityIndicator()
        }
        else {
            _view()
        }
    }

    func _view() -> some View {
        VStack {
            HStack {
                Text(String(format: "Weather forecast:"))
                Spacer()
            }
            Chart {
                ForEach(viewModel.forecast) { forecast in
                    LineMark(
                        x: .value("Date", forecast.date.nearestHour() ?? Date.now),
                        y: .value("Temperature", forecast.temperature.value)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(.blue.opacity(0.0))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    AreaMark(
                        x: .value("Date", forecast.date.nearestHour() ?? Date.now),
                        yStart: .value("Temperature", -20),
                        yEnd: .value("Temperature", forecast.temperature.value)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(linearGradient)
                }

                if let currentDate = Date.now.nextNearestHour(),
                    let currentTemperature = viewModel.forecast.first(where: { $0.date == currentDate })?.temperature
                {
                    RuleMark(x: .value("Date", currentDate))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", currentDate),
                        y: .value("Temperature", currentTemperature.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .topTrailing, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", currentDate.dateString(), currentDate.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f%@", currentTemperature.value, currentTemperature.unit.symbol))
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
                if let selectedDate, let selectedTemperature = viewModel.forecast.first(where: { $0.date == selectedDate })?.temperature {
                    RuleMark(x: .value("Date", selectedDate.nearestHour() ?? Date.now))
                        .lineStyle(StrokeStyle(lineWidth: 1))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Temperature", selectedTemperature.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomTrailing, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack {
                            Text(String(format: "%@ %@", selectedDate.dateString(), selectedDate.timeString()))
                                .font(.footnote)
                            HStack {
                                Text(String(format: "%.1f%@", selectedTemperature.value, selectedTemperature.unit.symbol))
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
            .chartYScale(domain: -20 ... 50)
            .chartOverlay { geometryProxy in
                GeometryReader { geometryReader in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let plotFrame = geometryProxy.plotFrame {
                                    let x = value.location.x - geometryReader[plotFrame].origin.x
                                    if let date: Date = geometryProxy.value(atX: x), let roundedHour = date.nearestHour() {
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
            HStack {
                Text("Last update: \(Date.absoluteString(date: viewModel.timestamp))")
                    .font(.footnote)
                Spacer()
            }
        }
    }
}
