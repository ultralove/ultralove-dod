import Foundation

extension Date {
   /// Returns a new Date object rounded to the nearest hour.
   func nearestHour() -> Date? {
      let calendar = Calendar.current

      // Extract hour and minute components from the date
      let components = calendar.dateComponents([.hour, .minute], from: self)

      // Determine the current hour and minute
      guard let hour = components.hour, let minute = components.minute else {
         return nil
      }

      // Calculate the new hour by rounding to the nearest hour
      var newHour = hour
      if minute >= 30 {
         newHour += 1 // Round up if 30 minutes or more
      }

      // Create a new Date object with the rounded hour
      var newComponents = calendar.dateComponents([.year, .month, .day], from: self)
      newComponents.hour = newHour
      newComponents.minute = 0
      newComponents.second = 0

      // Return the new date
      return calendar.date(from: newComponents)
   }

   func nextNearestHour() -> Date? {
      let calendar = Calendar.current

      // Get the current hour components
      let currentHour = calendar.component(.hour, from: self)

      // Get the next hour by rounding up
      var nextHourDateComponents = calendar.dateComponents([.year, .month, .day, .hour], from: self)
      nextHourDateComponents.hour = currentHour + 1
      nextHourDateComponents.minute = 0
      nextHourDateComponents.second = 0

      // Return the next hour date
      return calendar.date(from: nextHourDateComponents)
   }

   private func absoluteString(fmtStr: String) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = fmtStr
      return String(format: "%@", formatter.string(from: self))
   }

   func relativeString() -> String {
      let formatter = RelativeDateTimeFormatter()
      formatter.unitsStyle = .full
      return String(format: "%@", formatter.string(for: self) ?? "<Unknown>")
   }

   func absoluteString() -> String {
      return self.absoluteString(fmtStr: "yyyy-MM-dd HH:mm")
   }

   static func absoluteString(date: Date?) -> String {
      guard let date else { return "<Unknown>" }
      return date.absoluteString()
   }

   func timeString() -> String {
      return self.absoluteString(fmtStr: "HH:mm")
   }

   func dateString() -> String {
      return self.absoluteString(fmtStr: "YYYY-MM-dd")
   }
}


