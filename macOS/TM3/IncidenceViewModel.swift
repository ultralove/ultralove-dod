import Foundation

@Observable class IncidenceViewModel: LocationViewModel {
    private let incidenceController = IncidenceController()

    var sensor: IncidenceSensor?
    var incidence: [Incidence] = []
    var current: Incidence?

        var faceplate: String {
        if let incidence = incidence.first(where: { $0.timestamp == Date.roundToLastDayChange(from: Date.now) })?.value {
            return String(format: "\(GreekLetters.mathematicalBoldCapitalOmicron.rawValue):%.1f", incidence)
        }
        return "\(GreekLetters.mathematicalItalicCapitalOmicron.rawValue):n/a"
    }

    var maxIncidence: Double {
        if let maxValue = incidence.map({ $0.value }).max() {
            return maxValue * 1.33
        }
        else {
            return 100.0
        }
    }

    var trendSymbol: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToLastDayChange(from: Date.now) {
            if let currentIncidence = incidence.first(where: { $0.timestamp == currentDate })?.value {
                if let nextDate = Date.roundToLastDayChange(from: Date.now.addingTimeInterval(60 * 60 * 24)) {
                    if let nextIncidence = incidence.first(where: { $0.timestamp == nextDate })?.value {
                        if currentIncidence > nextIncidence {
                            symbol = "arrow.down.forward.circle"
                        }
                        else if currentIncidence < nextIncidence {
                            symbol = "arrow.up.forward.circle"
                        }
                        else {
                            symbol = "arrow.right.circle"
                        }
                    }
                }
            }
        }
        return symbol
    }

    @MainActor override func refreshData(location: Location) async -> Void {
        do {
//            self.timestamp = nil
            if let incidenceSensor = try await incidenceController.refreshIncidence(for: location) {
                self.sensor = incidenceSensor
                self.incidence = incidenceSensor.incidence
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")
        }
    }
}
