import SwiftUI
import CoreLocation

// Shared state that manages the `CLLocationManager` and `CLBackgroundActivitySession`.
@MainActor class LocationsHandler: ObservableObject {

   static let shared = LocationsHandler()  // Create a single, shared instance of the object.
   private let manager: CLLocationManager
   #if os(iOS)
   private var background: CLBackgroundActivitySession?
   #endif

   @Published var lastLocation = CLLocation()
   @Published var isStationary = false
   @Published var count = 0

   @Published
   var updatesStarted: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
      didSet { UserDefaults.standard.set(updatesStarted, forKey: "liveUpdatesStarted") }
   }

   #if os(iOS)
   @Published
   var backgroundActivity: Bool = UserDefaults.standard.bool(forKey: "BGActivitySessionStarted") {
      didSet {
         backgroundActivity ? self.background = CLBackgroundActivitySession() : self.background?.invalidate()
         UserDefaults.standard.set(backgroundActivity, forKey: "BGActivitySessionStarted")
      }
   }
   #endif

   private init() {
      self.manager = CLLocationManager()  // Creating a location manager instance is safe to call here in `MainActor`.
   }

   func startLocationUpdates() {
      if self.manager.authorizationStatus == .notDetermined {
         self.manager.requestWhenInUseAuthorization()
      }
      Task() {
         do {
            self.updatesStarted = true
            let updates = CLLocationUpdate.liveUpdates()
            for try await update in updates {
               if !self.updatesStarted { break }  // End location updates by breaking out of the loop.
               if let location = update.location {
                  self.lastLocation = location
                  self.isStationary = update.stationary
                  self.count += 1
                  print("Location \(self.count): \(self.lastLocation)")
               }
            }
         } catch {
            print("Could not start location updates")
         }
         return
      }
   }

   func stopLocationUpdates() {
      print("Stopping location updates")
      self.updatesStarted = false
      self.isStationary = false
   }
}

