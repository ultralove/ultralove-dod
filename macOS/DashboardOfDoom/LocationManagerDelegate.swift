import Foundation

protocol LocationManagerDelegate: Identifiable where ID == UUID {
    func locationManager(didUpdateLocation location: Location) -> Void
}



