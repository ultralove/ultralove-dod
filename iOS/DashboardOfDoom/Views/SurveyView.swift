import Charts
import SwiftUI

struct SurveyView: View {
    @Environment(SurveyPresenter.self) private var presenter

    var body: some View {
        VStack {
            if presenter.timestamp == nil {
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
                
                ForEach(ProcessSelector.Survey.allCases, id: \.self) { selector in
                    if self.presenter.isAvailable(selector: .survey(selector)) {
                        VStack {
                            SurveyChartView(selector: .survey(selector), rounding: .lastUTCDayChange)
                        }
                        .padding(.vertical, 5)
                        .frame(height: 167)
                    }
                }
            }
        }
        .padding(5)
        .padding(.trailing, 3)
    }
}
