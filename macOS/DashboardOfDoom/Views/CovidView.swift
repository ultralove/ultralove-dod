import Charts
import SwiftUI

struct CovidView: View {
    @Environment(CovidPresenter.self) private var presenter

    var body: some View {
        VStack {
            if self.presenter.timestamp == nil {
                ActivityIndicator()
            }
            else {
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

                ForEach(ProcessSelector.Covid.allCases, id: \.self) { selector in
                    if self.presenter.isAvailable(selector: .covid(selector)) {
                        VStack {
                            CovidChartView(selector: .covid(selector), rounding: .lastDayChange)
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
