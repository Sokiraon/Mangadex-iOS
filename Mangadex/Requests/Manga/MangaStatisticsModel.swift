//
// Created by John Rion on 9/1/22.
//

import Foundation

struct MangaRatingModel: Codable {
    let average: Double?
    let bayesian: Double?
}

struct MangaStatisticsModel: Codable {
    var follows: Int = 0
    var rating: MangaRatingModel?
    
    var followsString: String {
        if follows > 1000000 {
            return "\(follows / 1000000)M"
        } else if follows > 1000 {
            return "\(follows / 1000)K"
        } else {
            return "\(follows)"
        }
    }
    
    private static let formatter = NumberFormatter().apply { formatter in
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
    }
    
    var ratingString: String {
        if let bayesian = rating?.bayesian {
            return Self.formatter
                .string(from: NSNumber(value: bayesian)) ?? "N/A"
        } else if let average = rating?.average {
            return Self.formatter
                .string(from: NSNumber(value: average)) ?? "N/A"
        }
        return "N/A"
    }
}
