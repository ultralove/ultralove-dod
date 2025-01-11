import Foundation

@Observable class IncidenceViewModel: LocationViewModel {
    private let incidenceController = IncidenceController()

    var sensor: IncidenceSensor?
    var incidence: [Incidence] = []
    var current: Incidence?
    var timestamp: Date? = nil

        var faceplate: String {
            if let incidence = incidence.first(where: { $0.timestamp == Date.roundToLastDayChange(from: Date.now) })?.value.value {
            return String(format: "\(GreekLetters.mathematicalBoldCapitalOmicron.rawValue):%.1f", incidence)
        }
        return "\(GreekLetters.mathematicalItalicCapitalOmicron.rawValue):n/a"
    }

    var maxIncidence: Measurement<UnitIncidence> {
        if let maxValue = incidence.map({ $0.value }).max() {
            return maxValue * 1.33
        }
        else {
            return Measurement<UnitIncidence>(value: 100.0, unit: .casesper100k)
        }
    }

    var trend: String {
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
            if let sensor = try await incidenceController.refreshIncidence(for: location) {
                self.sensor = sensor
                self.incidence = sensor.incidence
                self.timestamp = sensor.timestamp
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")
        }
    }
}
