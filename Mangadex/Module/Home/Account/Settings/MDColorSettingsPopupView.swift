//
//  MDColorSettingsPopupView.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/10.
//

import Foundation
import SwiftTheme

class MDColorSettingsPopupView: MDSettingsPopupView {
    
    override func viewDidAppear() {
        super.viewDidAppear()

        vOptCollection.scrollToItem(
            at: IndexPath(row: ThemeManager.currentThemeIndex, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
    }
    
    override func itemSize() -> CGSize {
        CGSize(width: 100, height: 88)
    }
    
    override func titleString() -> String {
        "kPrefThemeColor".localized()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        UIColor.primaryColors.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
        (cell as? MDColorSettingCollectionCell)?
            .setColor(UIColor.primaryColors[indexPath.row])
        return cell
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView, atIndexPath indexPath: IndexPath) {
        MDSettingsManager.themeColorIndex = indexPath.row
        ThemeManager.setTheme(index: MDSettingsManager.themeColorIndex)
    }
}
