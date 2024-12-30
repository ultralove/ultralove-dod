import Foundation

func degreesToRadians(_ degrees: Double) -> Double {
    return degrees * .pi / 180
}

func radiusAtLocation(_ latitude: Double) -> Double {
    let polarRadius = Measurement(value: 6356752.3, unit: UnitLength.meters)
    let equatorialRadius = Measurement(value: 6378137.0, unit: UnitLength.meters)
    return sqrt(pow(polarRadius.value, 2) * pow(cos(latitude), 2) + pow(equatorialRadius.value, 2) * pow(sin(latitude), 2))
        / sqrt(pow(polarRadius.value * cos(latitude), 2) + pow(equatorialRadius.value * sin(latitude), 2))
}

func averageRadius(_ latitude_0: Double, _ latidude_1: Double) -> Double {
    return (radiusAtLocation(latitude_0) + radiusAtLocation(latidude_1)) / 2
}

func haversineDistance(latitude_0: Double, longitude_0: Double, latitude_1: Double, longitude_1: Double) -> Measurement<UnitLength> {

    let lat1 = degreesToRadians(latitude_0)
    let lon1 = degreesToRadians(longitude_0)

    let lat2 = degreesToRadians(latitude_1)
    let lon2 = degreesToRadians(longitude_1)

    let latitudeDistance = lat2 - lat1
    let longitudeDistance = lon2 - lon1

    let a =
        pow(sin(latitudeDistance / 2), 2) +
        cos(lat1) *
        cos(lat2) *
        pow(sin(longitudeDistance / 2), 2)

    let c = 2 * asin(sqrt(a))

    let R = 6371000.0 // Radius of the Earth in meters

    let distance = R * c

    return Measurement(value: distance, unit: UnitLength.meters)


//    return Measurement(value: averageRadius(latitude_0, latitude_1) * c, unit: UnitLength.meters)

}

func haversineDistance(location_0: Location, location_1: Location) -> Measurement<UnitLength> {
    return haversineDistance(
        latitude_0: location_0.latitude, longitude_0: location_0.longitude,
        latitude_1: location_1.latitude, longitude_1: location_1.longitude)
}
