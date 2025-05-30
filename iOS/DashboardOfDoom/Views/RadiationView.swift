import Charts
import SwiftUI

struct RadiationView: View {
    @Environment(RadiationPresenter.self) private var presenter

    var body: some View {
        VStack {
            if self.presenter.timestamp == nil {
                ActivityIndicator()
            }
            else {
                #if os(macOS)
                HStack(alignment: .bottom) {
                    HStack {
                        Image(systemName: "safari")
                        Text(String(format: "%@", self.presenter.placemark))
                    }
                    Spacer()
                    Text("Last update: \(Date.absoluteString(date: self.presenter.timestamp))")
                        .foregroundColor(.gray)
                }
                .font(.footnote)
                #else
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "safari")
                        Text(String(format: "%@", self.presenter.placemark))
                        Spacer()
                    }
                    HStack {
                        Text("Last update: \(Date.absoluteString(date: self.presenter.timestamp))")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .font(.footnote)
                #endif
                
                ForEach(ProcessSelector.Radiation.allCases, id: \.self) { selector in
                    if self.presenter.isAvailable(selector: .radiation(selector)) {
                        VStack {
                            RadiationChartView(selector: .radiation(selector), rounding: .previousHour)
                        }
                        .padding(.vertical, 5)
                        .frame(height: 167)
                    }
                }
            }
        }
    }
}
