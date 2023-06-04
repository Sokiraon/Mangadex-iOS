//
// Created by John Rion on 9/1/22.
//

import Foundation
import YYModel

class MangaRatingModel: NSObject, YYModel {
    @objc var average: NSNumber?
    @objc var bayesian: NSNumber?
}

class MangaStatisticsModel: NSObject, YYModel {
    @objc var follows: Int = 0
    @objc var rating: MangaRatingModel?
    
    class func modelContainerPropertyGenericClass() -> [String: Any]? {
        [
            "rating": MangaRatingModel.classForCoder()
        ]
    }
    
    lazy var followsString: String = {
        if follows > 1000000 {
            return "\(follows / 1000000)M"
        } else if follows > 1000 {
            return "\(follows / 1000)K"
        } else {
            return "\(follows)"
        }
    }()
    
    private static let formatter = NumberFormatter().apply { formatter in
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
    }
    
    lazy var ratingString: String? = {
        if rating?.bayesian != nil {
            return Self.formatter.string(from: rating!.bayesian!)
        } else if rating?.average != nil {
            return Self.formatter.string(from: rating!.average!)
        }
        return "N/A"
    }()
}
