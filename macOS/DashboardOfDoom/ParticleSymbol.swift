import Foundation

enum ParticleSymbol: String, CaseIterable {
    case pm10 = "\u{1D40F}\u{1D40C}\u{2081}\u{2080}"  // PM10, Particulate matter < 10µm
    case co = "\u{1D402}\u{1D40E}"  // CO, Carbon monoxide
    case o3 = "\u{1D40E}\u{2083}"  // O3, Ozone
    case so2 = "\u{1D412}\u{1D40E}\u{2082}"  // SO2, Sulfur dioxide
    case no2 = "\u{1D40D}\u{1D40E}\u{2082}"  // NO2, Nitrogen dioxide
    case lead = "\u{1D40F}\u{1D41B}"  // Pb, Lead in particulate matter < 10µm
    case benzoapyrene = "\u{1D402}\u{2082}\u{2080}\u{1D407}\u{2081}\u{2082}"  // C20H12, Benzo(a)pyrene in particulate matter < 10µm
    case benzene = "\u{1D402}\u{2086}\u{1D407}\u{2086}"  // C6H6, Benzene
    case pm25 = "\u{1D40F}\u{1D40C}\u{2082}\u{2085}"  // Particulate matter < 2.5µm
    case arsenic = "\u{1D400}\u{1D42C}"  // As, Arsenic in particulate matter < 10µm
    case cadmium = "\u{1D402}\u{1D41D}"  // Cd, Cadmium in particulate matter < 10µm
    case nickel = "\u{1D40D}\u{1D422}"  // Ni, Nickel in particulate matter < 10µm
}
