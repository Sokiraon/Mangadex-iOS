//
//  MDColorSettingsPopupView.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/10.
//

import Foundation
import SwiftTheme

class MDColorSettingsPopupView: MDSettingsPopupView {
    override func itemSize() -> CGSize {
        CGSize(width: 100, height: 80)
    }
    
    override func titleString() -> String {
        "kPrefThemeColor".localized()
    }
    
    override func didTapSave() {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        MDThemeColors.allCases.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
        (cell as! MDColorSettingCollectionCell).setColor(MDThemeColors.allCases[indexPath.row])
        return cell
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        
        let centerX = vOptCollection.contentOffset.x + (MDLayout.screenWidth - 20) / 2
        guard let indexPath = vOptCollection
                .indexPathForItem(at: CGPoint(x: centerX, y: itemSize().height / 2)) else {
                    return
                }
        ThemeManager.setTheme(index: indexPath.row)
    }
}
