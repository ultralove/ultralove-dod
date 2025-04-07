import Foundation

class PointOfInterest: Identifiable {
    let id = UUID()
    let name: String
    let location: Location

    init(name: String, location: Location) {
        self.name = name
        self.location = location
    }
}

