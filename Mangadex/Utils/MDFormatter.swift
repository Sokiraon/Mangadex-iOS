//
//  MDFormatter.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/7.
//

import Foundation

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
        return dateFormatter.string(from: isoFormatter.date(from: string)!)
    }
}
