import Foundation

enum ProcessSelector: Hashable {
    case weather(Weather)
    case forecast(Forecast)
    case covid(Covid)
    case water(Water)
    case particle(Particle)
    case radiation(Radiation)
    case survey(Survey)

    enum Weather: Int, CaseIterable {
        case temperature = 0
        case apparentTemperature = 1
        case dewPoint = 2
        case humidity = 3
        case precipitationIntensity = 4
        case pressure = 5
        case visibility = 6
        case cloudCover = 7
        case cloudCoverLow = 8
        case cloudCoverMedium = 9
        case cloudCoverHigh = 10
        case windSpeed = 11
        case windGust = 12
    }

    enum Forecast: Int, CaseIterable {
        case temperature = 0
        case apparentTemperature = 1
        case dewPoint = 2
        case humidity = 3
        case precipitationChance = 4
        case precipitationAmount = 5
        case pressure = 6
        case visibility = 7
        case cloudCover = 8
        case windSpeed = 9
        case windGust = 10
    }

    enum Covid: Int, CaseIterable {
        case incidence = 0
        case cases = 1
        case deaths = 2
        case recovered = 3
    }

    enum Water: Int, CaseIterable {
        case level = 0
    }

    enum Radiation: Int, CaseIterable {
        case total = 0
        case cosmic = 1
        case terrestrial = 2
    }

    enum Particle: Int, CaseIterable, RawRepresentable {
        case all = -1
        case pm10 = 1  // Particulate matter < 10µm
        case pm25 = 9  // Particulate matter < 2.5µm
        case o3 = 3  // Ozone
        case no2 = 5  // Nitrogen dioxide
        case co = 2  // Carbon monoxide
        case so2 = 4  // Sulfur dioxide
        case lead = 6  // Lead in particulate matter < 10µm
        case benzoapyrene = 7  // Benzo(a)pyrene in particulate matter < 10µm
        case benzene = 8  // Benzene
        case arsenic = 10  // Arsenic in particulate matter < 10µm
        case cadmium = 11  // Cadmium in particulate matter < 10µm
        case nickel = 12  // Nickel in particulate matter < 10µm
    }

    static func particle(from rawValue: Int) -> ProcessSelector? {
        guard let particle = Particle(rawValue: rawValue) else {
            return nil
        }
        return .particle(particle)
    }

    enum Survey: Int, CaseIterable, RawRepresentable {
        case fascists = 999
        case clowns = 998
        case linke = 5
        case gruene = 4
        case spd = 2
        case fdp = 3
        case afd = 7
        case bsw = 23
        case cducsu = 1
        case sonstige = 0
        case piraten = 6
        case freie_waehler = 8
        case npd = 9
        case ssw = 10
        case bayernpartei = 11
        case oedp = 12
        case partei = 13
        case bvb_fw = 14
        case tierschutz = 15
        case biw = 16
        case familie = 17
        case volt = 18
        case bunt_saar = 21
        case bfth = 22
        case plus_brandenburg = 24
        case werte_union = 25
        case cdu = 101
        case csu = 102
    }

    static func survey(from rawValue: Int) -> ProcessSelector? {
        guard let survey = Survey(rawValue: rawValue) else {
            return nil
        }
        return .survey(survey)
    }

    var rawValue: Int {
        switch self {
            case .weather(let weatherType):
                return weatherType.rawValue
            case .forecast(let forecastType):
                return forecastType.rawValue
            case .covid(let covidType):
                return covidType.rawValue
            case .water(let waterType):
                return waterType.rawValue
            case .particle(let particleType):
                return particleType.rawValue
            case .radiation(let radiationType):
                return radiationType.rawValue
            case .survey(let surveyType):
                return surveyType.rawValue
        }
    }
}


