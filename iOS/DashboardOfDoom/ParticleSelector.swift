import Foundation

enum ParticleSelector: Int {
    case pm10 = 1  // Particulate matter < 10µm
    case co = 2  // Carbon monoxide
    case o3 = 3  // Ozone
    case so2 = 4  // Sulfur dioxide
    case no2 = 5  // Nitrogen dioxide
    case lead = 6  // Lead in particulate matter < 10µm
    case benzoapyrene = 7  // Benzo(a)pyrene in particulate matter < 10µm
    case benzene = 8  // Benzene
    case pm25 = 9  // Particulate matter < 2.5µm
    case arsenic = 10  // Arsenic in particulate matter < 10µm
    case cadmium = 11  // Cadmium in particulate matter < 10µm
    case nickel = 12  // Nickel in particulate matter < 10µm
}
