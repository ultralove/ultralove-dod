import CoreLocation
import Foundation

// Custom class that manages location updates asynchronously
class AsyncLocationManager: NSObject, CLLocationManagerDelegate {
   private let locationManager = CLLocationManager()

   // Continuation for location updates
   private var locationContinuation: CheckedContinuation<CLLocation, Error>?

   override init() {
      super.init()
      locationManager.delegate = self
   }

   // Async function to request the current location
   func requestLocation() async throws -> CLLocation {
      // Check for location services permission
      guard CLLocationManager.locationServicesEnabled() else {
         throw LocationError.locationServicesDisabled
      }

      // Check authorization status
      let authStatus = locationManager.authorizationStatus
      if authStatus == .notDetermined {
         locationManager.requestAlwaysAuthorization ()
      } else if authStatus != .authorizedAlways {
         throw LocationError.unauthorized
      }

      // Request the location asynchronously using continuation
      return try await withCheckedThrowingContinuation { continuation in
         self.locationContinuation = continuation
         locationManager.requestLocation()
      }
   }

   // CLLocationManagerDelegate method to handle location updates
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let location = locations.first {
         locationContinuation?.resume(returning: location)
         locationContinuation = nil
      }
   }

   // CLLocationManagerDelegate method to handle errors
   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      locationContinuation?.resume(throwing: error)
      locationContinuation = nil
   }

   enum LocationError: Error {
      case locationServicesDisabled
      case unauthorized
   }
}

