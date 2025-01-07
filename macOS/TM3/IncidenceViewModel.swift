import Foundation

@Observable class IncidenceViewModel: LocationViewModel {
    private let incidenceController = IncidenceController()

    var station: String?
    var incidence: [Incidence] = []
    var timestamp: Date? = nil

    var faceplate: String {
        if let incidence = incidence.first(where: { $0.date == Date.roundToLastDayChange(from: Date.now) })?.incidence {
            return String(format: "\(GreekLetters.mathematicalBoldCapitalOmicron.rawValue):%.1f", incidence)
        }
        return "\(GreekLetters.mathematicalItalicCapitalOmicron.rawValue):n/a"
    }

    var maxIncidence: Double {
        if let maxValue = incidence.map({ $0.incidence }).max() {
            return maxValue * 1.33
        }
        else {
            return 100.0
        }
    }

    var trendSymbol: String {
        var symbol = "questionmark.circle"
        if let currentDate = Date.roundToLastDayChange(from: Date.now) {
            if let currentIncidence = incidence.first(where: { $0.date == currentDate })?.incidence {
                if let nextDate = Date.roundToLastDayChange(from: Date.now.addingTimeInterval(60 * 60 * 24)) {
                    if let nextIncidence = incidence.first(where: { $0.date == nextDate })?.incidence {
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
            self.timestamp = nil
            if let incidenceSensor = try await incidenceController.refreshIncidence(for: location) {
                self.station = incidenceSensor.station
                self.incidence = incidenceSensor.incidence
                self.timestamp = incidenceSensor.timestamp
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")
        }
    }
}
