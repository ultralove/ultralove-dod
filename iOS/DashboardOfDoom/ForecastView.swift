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
                    .font(.headline)
                Spacer()
            }
            Chart {
                ForEach(viewModel.forecast.prefix(7 * 24)) { forecast in
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
                    .annotation(position: .topTrailing, spacing: 0) {
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
                        .background(.opacity(0.125))
                        .foregroundStyle(.black)
                        .clipShape(.capsule(style: .continuous))
                    }
                }
                #if os(macOS)
                if let selectedDate, let selectedTemperature = viewModel.forecast.first(where: { $0.date == selectedDate })?.temperature {
                    RuleMark(x: .value("Date", selectedDate.nearestHour() ?? Date.now))
                        .symbolSize(CGSize(width: 3, height: 3))
                    PointMark(
                        x: .value("Date", selectedDate),
                        y: .value("Temperature", selectedTemperature.value)
                    )
                    .symbolSize(CGSize(width: 7, height: 7))
                    .annotation(position: .bottomTrailing, spacing: 0) {
                        HStack {
                            Text(String(format: "%@ %.1f%@", selectedDate.timeString(), selectedTemperature.value, selectedTemperature.unit.symbol))
                        }
                        .font(.headline)
                    }
                }
                #endif
            }
            .chartYScale(domain: -20 ... 50)
            #if os(macOS)
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
            #endif
            HStack {
                Text("Last update: \(Date.absoluteString(date: viewModel.timestamp))")
                    .font(.footnote)
                Spacer()
            }
        }
    }
}

