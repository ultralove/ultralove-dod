import Charts
import SwiftUI

struct RadiationView: View {
    @Environment(RadiationViewModel.self) private var viewModel

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
                Text(String(format: "Radiation at station %@:", viewModel.station?.name ?? "<Unknown>"))
                    .font(.headline)
                Spacer()
            }
            Chart {
                BarMark(x: .value("Total", "Total"), y: .value("Radiation", viewModel.radiation?.total.value ?? Double.nan))
                    .foregroundStyle(linearGradient)
                    .annotation {
                        Text(String(format: "%.3f%@", viewModel.radiation?.total.value ?? Double.nan, viewModel.radiation?.total.unit.symbol ?? ""))
                            .font(.headline)
                    }
                    .alignsMarkStylesWithPlotArea()

                BarMark(x: .value("Cosmic", "Cosmic"), y: .value("Radiation", viewModel.radiation?.cosmic?.value ?? Double.nan))
                    .foregroundStyle(linearGradient)
                    .annotation {
                        Text(String(format: "%.3f%@", viewModel.radiation?.cosmic?.value ?? Double.nan, viewModel.radiation?.cosmic?.unit.symbol ?? ""))
                            .font(.headline)
                    }
                    .alignsMarkStylesWithPlotArea()
                BarMark(x: .value("Terrestrial", "Terrestrial"), y: .value("Radiation", viewModel.radiation?.terrestrial?.value ?? Double.nan))
                    .foregroundStyle(linearGradient)
                    .annotation {
                        Text(String(format: "%.3f%@", viewModel.radiation?.terrestrial?.value ?? Double.nan, viewModel.radiation?.terrestrial?.unit.symbol ?? ""))
                            .font(.headline)
                    }
                    .alignsMarkStylesWithPlotArea()
            }
            HStack {
                Text("Last update: \(Date.absoluteString(date: viewModel.timestamp ?? Date.now))")
                    .font(.footnote)
                Spacer()
            }
        }
    }
}

#Preview {
    RadiationView()
}
