//
// Created by John Rion on 2021/7/10.
//

import Foundation
import UIKit

class ShortTapGestureRecognizer: UITapGestureRecognizer {
    private let maxDelayMilli = 200
    var isContinuous: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if (isContinuous) {
            state = .recognized
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(maxDelayMilli)) {
            if (self.isContinuous && self.state != .recognized) {
                self.isContinuous = false
                self.state = .failed
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        if (state == .recognized) {
            isContinuous = true
        }
    }
}
