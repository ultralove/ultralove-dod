import Foundation

@Observable class IncidenceViewModel: LocationViewModel {
    private let incidenceController = IncidenceController()

    static let shared = IncidenceViewModel()

    var incidence: [Incidence] = []
    var lastUpdate: Date? = nil

    var faceplate: String {
        if let incidence = incidence.first(where: { $0.date == Self.nearestDataPoint(from: Date.now) })?.incidence {
            return String(format: "\(GreekLetters.mathematicalBoldCapitalOmicron.rawValue):%.1f", incidence)
        }
        return "\(GreekLetters.mathematicalItalicCapitalOmicron.rawValue):n/a"
    }

    var trendSymbol: String {
        var symbol = "questionmark.circle"
        if let currentDate = Self.nearestDataPoint(from: Date.now) {
            if let currentIncidence = incidence.first(where: { $0.date == currentDate })?.incidence {
                if let nextDate = Self.nearestDataPoint(from: Date.now.addingTimeInterval(60 * 60 * 24)) {
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

    override func refreshData(location: Location) async -> Void {
        do {
            self.lastUpdate = nil
            if let incidenceSensor = try await incidenceController.refreshIncidence(for: location) {
                self.location = incidenceSensor.location
                self.incidence = incidenceSensor.incidence
                self.lastUpdate = Date.now
            }
        }
        catch {
            print("Error refreshing data: \(error.localizedDescription)")
        }
    }

    static func nearestDataPoint(from: Date) -> Date? {
        var components = DateComponents()
        components.year = Calendar.current.component(.year, from: from)
        components.month = Calendar.current.component(.month, from: from)
        components.day = Calendar.current.component(.day, from: from)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(abbreviation: "UTC")
        return Calendar.current.date(from: components)
    }
}
