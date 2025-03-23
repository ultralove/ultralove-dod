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
        case cloudCover = 0
        case dewPoint = 1
        case humidity = 2
        case precipitationChance = 3
        case precipitationAmount = 4
        case snowfallAmount = 5
        case pressure = 6
        case temperature = 7
        case apparentTemperature = 8
        case visibility = 9
        case windDirection = 10
        case windSpeed = 11
        case windGust = 12
    }

    enum Forecast: Int, CaseIterable {
        case temperature = 7
        case apparentTemperature = 8
        case dewPoint = 1
        case humidity = 2
        case precipitationChance = 3
        case precipitationAmount = 4
        case pressure = 6
        case visibility = 9
        case cloudCover = 0
        case windSpeed = 11
        case windGust = 12
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
        case sonstige = 0
        case cducsu = 1
        case spd = 2
        case fdp = 3
        case gruene = 4
        case linke = 5
        case piraten = 6
        case afd = 7
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
        case bsw = 23
        case plus_brandenburg = 24
        case werte_union = 25
        case cdu = 101
        case csu = 102
        case clowns = 998
        case fascists = 999
    }

    static func survey(from rawValue: Int) -> ProcessSelector? {
        guard let survey = Survey(rawValue: rawValue) else {
            return nil
        }
        return .survey(survey)
    }
}


