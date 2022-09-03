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
    @objc var follows: NSNumber?
    @objc var rating: MangaRatingModel?
    
    class func modelContainerPropertyGenericClass() -> [String: Any]? {
        [
            "rating": MangaRatingModel.classForCoder()
        ]
    }
}
