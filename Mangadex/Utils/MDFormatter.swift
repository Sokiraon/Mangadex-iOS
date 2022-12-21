//
//  MDFormatter.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/7.
//

import Foundation
import Localize_Swift

class MDFormatter {
    static private var isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withDashSeparatorInDate,
            .withFullDate,
            .withFractionalSeconds,
            .withColonSeparatorInTimeZone
        ]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
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
    
    static func dateStringFromNow(isoDateString string: String) -> String {
        guard let date = date(fromISODateString: string) else {
            return "N/A"
        }
        let dateDelta = Int(abs(Date.now.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate))
        let minuteLength = 60
        let hourLength = 60 * minuteLength
        let dayLength = 24 * hourLength
        let monthLength = 30 * dayLength
        let yearLength = 365 * dayLength
        if dateDelta >= yearLength {
            let years = dateDelta / yearLength
            if years > 1 {
                return "kTimeDeltaYears".localizedFormat(years)
            } else {
                return "kTimeDeltaOneYear".localized()
            }
        } else if dateDelta >= monthLength {
            let months = dateDelta / monthLength
            if months > 1 {
                return "kTimeDeltaMonths".localizedFormat(months)
            } else {
                return "kTimeDeltaOneMonth".localized()
            }
        } else if dateDelta >= dayLength {
            let days = dateDelta / dayLength
            if days > 1 {
                return "kTimeDeltaDays".localizedFormat(days)
            } else {
                return "kTimeDeltaOneDay".localized()
            }
        } else if dateDelta >= hourLength {
            let hours = dateDelta / hourLength
            if hours > 1 {
                return "kTimeDeltaHours".localizedFormat(hours)
            } else {
                return "kTimeDeltaOneHour".localized()
            }
        } else if dateDelta >= minuteLength {
            let minutes = dateDelta / minuteLength
            if minutes > 1 {
                return "kTimeDeltaMinutes".localizedFormat(minutes)
            } else {
                return "kTimeDeltaOneMinute".localized()
            }
        } else {
            return "kTimeDeltaLatest".localized()
        }
    }
}
