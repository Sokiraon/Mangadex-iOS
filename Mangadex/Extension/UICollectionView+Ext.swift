//
//  UICollectionView+Ext.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/10.
//

import Foundation
import UIKit

extension UICollectionView {
    func scrollToNearestVisibleCell() -> IndexPath? {
        self.decelerationRate = .fast
        let collectionViewCenter = Float(self.contentOffset.x + (self.bounds.size.width / 2))
        var closestCellIndex = self.indexPathForItem(
            at: CGPoint(x: CGFloat(collectionViewCenter), y: self.bounds.size.height / 2)
        )
        if closestCellIndex == nil {
            var closestDistance: Float = .greatestFiniteMagnitude
            for cell in self.visibleCells {
                let cellWidth = cell.bounds.size.width
                let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)
                let distance = fabsf(collectionViewCenter - cellCenter)
                if distance < closestDistance {
                    closestDistance = distance
                    closestCellIndex = self.indexPath(for: cell)
                }
            }
        }
        
        if closestCellIndex != nil {
            self.scrollToItem(at: closestCellIndex!, at: .centeredHorizontally, animated: true)
        }
        return closestCellIndex
    }
}
