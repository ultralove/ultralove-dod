import Foundation

enum ParticleSelector: Int, CaseIterable {
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

