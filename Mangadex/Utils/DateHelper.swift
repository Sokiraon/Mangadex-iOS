//
//  DateHelper.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/7.
//

import Foundation
import Localize_Swift

class DateHelper {
    
    static private var isoFormatter = ISO8601DateFormatter().apply { formatter in
        formatter.formatOptions = [.withInternetDateTime]
    }
    
    static private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static func formattedDateString(fromISODateString string: String) -> String {
        dateFormatter.string(from: isoFormatter.date(from: string)!)
    }
    
    static func date(fromISODateString string: String) -> Date? {
        isoFormatter.date(from: string)
    }
    
    /// Returns a string to represent the timeDelta from the given dateString to now.
    static func dateStringFromNow(isoDateString string: String) -> String {
        guard let date = date(fromISODateString: string) else {
            return "N/A"
        }
        let timeDelta = Int(abs(Date.now.timeIntervalSince(date)))
        let minuteLength = 60
        let hourLength = 60 * minuteLength
        let dayLength = 24 * hourLength
        let monthLength = 30 * dayLength
        let yearLength = 365 * dayLength
        if timeDelta >= yearLength {
            let years = timeDelta / yearLength
            if years > 1 {
                return "kTimeDeltaYears".localizedFormat(years)
            } else {
                return "kTimeDeltaOneYear".localized()
            }
        } else if timeDelta >= monthLength {
            let months = timeDelta / monthLength
            if months > 1 {
                return "kTimeDeltaMonths".localizedFormat(months)
            } else {
                return "kTimeDeltaOneMonth".localized()
            }
        } else if timeDelta >= dayLength {
            let days = timeDelta / dayLength
            if days > 1 {
                return "kTimeDeltaDays".localizedFormat(days)
            } else {
                return "kTimeDeltaOneDay".localized()
            }
        } else if timeDelta >= hourLength {
            let hours = timeDelta / hourLength
            if hours > 1 {
                return "kTimeDeltaHours".localizedFormat(hours)
            } else {
                return "kTimeDeltaOneHour".localized()
            }
        } else if timeDelta >= minuteLength {
            let minutes = timeDelta / minuteLength
            if minutes > 1 {
                return "kTimeDeltaMinutes".localizedFormat(minutes)
            } else {
                return "kTimeDeltaOneMinute".localized()
            }
        } else {
            return "kTimeDeltaLatest".localized()
        }
    }
    
    static func dateStringFromNow(year: Int = 0, month: Int = 0, day: Int = 0) -> String {
        let date = Calendar.current.date(byAdding: DateComponents(year: year, month: month, day: day),
                                         to: Date())
        return isoFormatter.string(from: date!)
    }
}
