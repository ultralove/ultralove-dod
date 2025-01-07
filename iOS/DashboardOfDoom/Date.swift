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
            newHour += 1  // Round up if 30 minutes or more
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

    static func roundToPreviousQuarterHour(from: Date) -> Date? {
        let calendar = Calendar.current

        // Extract hour, minute, and second components from the input date
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: from)

        guard let minute = components.minute else { return nil }

        // Calculate the remainder when dividing minutes by 15
        let remainder = minute % 15

        // Adjust to the previous quarter hour
        var adjustedComponents = components
        adjustedComponents.minute = minute - remainder
        adjustedComponents.second = 0  // Set seconds to 0 for clean rounding

        // Create a new date using the adjusted components
        return calendar.date(from: adjustedComponents)
    }

    static func roundToPreviousHour(from: Date) -> Date? {
        let calendar = Calendar.current

        // Extract year, month, day, hour components from the input date
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: from)

        guard let hour = components.hour else { return nil }

        // Adjust to the previous hour
        var adjustedComponents = components
        adjustedComponents.hour = hour
        adjustedComponents.minute = 0 // Reset minutes to 0
        adjustedComponents.second = 0 // Reset seconds to 0

        // Create a new date using the adjusted components
        return calendar.date(from: adjustedComponents)
    }

    static func roundToLastDayChange(from: Date) -> Date? {
        let calendar = Calendar.current

        // Extract year, month, day, hour components from the input date
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: from)

        // Adjust to the previous hour
        var adjustedComponents = components
        adjustedComponents.hour = 0    // Reset hours to 0
        adjustedComponents.minute = 0  // Reset minutes to 0
        adjustedComponents.second = 0  // Reset seconds to 0
        adjustedComponents.timeZone = TimeZone.current

        // Create a new date using the adjusted components
        return calendar.date(from: adjustedComponents)
    }

    static func roundToNextQuarterHour(from date: Date) -> Date? {
        // Get the current calendar
        let calendar = Calendar.current

        // Extract hour, minute, and other components from the date
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        // Calculate the next quarter hour
        if let minute = components.minute {
            let remainder = minute % 15
            let minutesToAdd = 15 - remainder

            // Add the minutes to reach the next quarter
            components.minute = minute + minutesToAdd
            components.second = 0 // Reset seconds to zero

            if let minutes = components.minute {
                if minutes >= 60 {
                    components.minute = minutes - 60
                    components.hour = (components.hour ?? 0) + 1
                    if components.hour == 24 {
                        // Adjust for day rollover
                        components.hour = 0
                        if let nextDay = calendar.date(byAdding: .day, value: 1, to: date) {
                            components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextDay)
                        }
                    }
                }
            }
            else {
                return nil
            }
        }

        // Create the next quarter-hour date
        return calendar.date(from: components)
    }

    static func roundToNextHour(from date: Date) -> Date? {
        // Get the current calendar
        let calendar = Calendar.current

        // Extract hour and other components from the date
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        // Increment the hour
        components.hour = (components.hour ?? 0) + 1
        components.minute = 0 // Reset minutes to zero
        components.second = 0 // Reset seconds to zero

        // Handle day rollover
        if components.hour == 24 {
            components.hour = 0
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: date) {
                components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextDay)
            }
        }

        // Create the next hour date
        return calendar.date(from: components)
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
