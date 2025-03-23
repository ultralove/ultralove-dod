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

                ForEach(ProcessSelector.Survey.allCases, id: \.self) { selector in
                    if self.presenter.isAvailable(selector: .survey(selector)) {
                        VStack {
                            SurveyChartView(selector: .survey(selector), rounding: .previousHour)
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
