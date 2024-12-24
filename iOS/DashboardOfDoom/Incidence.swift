import Foundation

struct Incidence: Identifiable, Sendable {
   let id = UUID()
   var incidence: Double
   var date: Date
}
