import Foundation

func degreesToRadians(_ degrees: Double) -> Double {
    return degrees * .pi / 180
}

func radiusAtLocation(_ latitude: Double) -> Double {
    let polarRadius = 6356752.314245  // m
    let equatorialRadius = 6378137.0  // m
    return sqrt(pow(polarRadius, 2) * pow(cos(latitude), 2) + pow(equatorialRadius, 2) * pow(sin(latitude), 2))
        / sqrt(pow(polarRadius * cos(latitude), 2) + pow(equatorialRadius * sin(latitude), 2))
}

func averageRadius(_ latitude_0: Double, _ latidude_1: Double) -> Double {
   return (radiusAtLocation(latitude_0) + radiusAtLocation(latidude_1)) / 2;
}

//func haversineDistance(latitude_1: Double, longitude_1: Double, latitude_2: Double, longitude_2: Double) -> Double {
//    let earthRadiusKm: Double = 6371.0  // Earth's radius in kilometers
//
//    // Convert latitudes and longitudes from degrees to radians
//    let latitudeRadius_1 = latitude_1 * .pi / 180
//    let longitudeRadius_1 = longitude_1 * .pi / 180
//    let latitudeRadius_2 = latitude_2 * .pi / 180
//    let longitudeRadius_2 = longitude_2 * .pi / 180
//
//    // Calculate the differences between the coordinates
//    let latitudeDistance = latitudeRadius_2 - latitudeRadius_1
//    let longitudeDistance = longitudeRadius_2 - longitudeRadius_1
//
//    // Apply the Haversine formula
//    let a =
//        sin(latitudeDistance / 2) * sin(latitudeDistance / 2) + cos(latitudeRadius_1) * cos(latitudeRadius_2) * sin(longitudeDistance / 2) * sin(longitudeDistance / 2)
//    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
//
//    // Compute the distance
//    let distance = earthRadiusKm * c
//
//    return distance
//}

func haversineDistance(latitude_0: Double, longitude_0: Double,
                       latitude_1: Double, longitude_1: Double) -> Double {
   let latitudeDistance = degreesToRadians(latitude_1 - latitude_0);
   let longitudeDistance = degreesToRadians(longitude_1 - longitude_0);
   let a = pow(sin(latitudeDistance / 2), 2) + pow(sin(longitudeDistance / 2), 2) * cos(degreesToRadians(latitude_0)) * cos(degreesToRadians(latitude_1));
   let c = 2 * asin(sqrt(a));
   return averageRadius(latitude_0, latitude_1) * c;
}

func haversineDistance(location_0: Location, location_1: Location) -> Double {
   return haversineDistance(latitude_0: location_0.latitude, longitude_0: location_0.longitude,
                            latitude_1: location_1.latitude, longitude_1: location_1.longitude);
}

