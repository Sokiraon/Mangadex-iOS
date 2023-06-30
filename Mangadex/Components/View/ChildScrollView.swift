//
//  ChildScrollView.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/28.
//

import Foundation
import UIKit

/// A custom scrollView that allows to scroll with another scrollView.
class ChildScrollView: UIScrollView, UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer,
           otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
}

/// A custom collectionView that allows to scroll with another scrollView.
class ChildCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer,
           otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
}
