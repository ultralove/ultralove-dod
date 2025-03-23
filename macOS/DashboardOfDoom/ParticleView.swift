import Charts
import SwiftUI

struct ParticleView: View {
    @Environment(ParticlePresenter.self) private var presenter

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

                ForEach(ProcessSelector.Particle.allCases, id: \.self) { selector in
                    if self.presenter.isAvailable(selector: .particle(selector)) {
                        VStack {
                            ParticleChartView(selector: .particle(selector), rounding: .previousHour)
                        }
                        .padding(.vertical, 5)
                        .frame(height: 167)
                    }
                }
            }
        }
        .padding(5)
        .padding(.trailing, 10)
        .cornerRadius(13)
    }
}
