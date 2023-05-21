//
//  MDLangSettingsPopupView.swift
//  Mangadex
//
//  Created by John Rion on 2022/1/12.
//

import Foundation
import FlagKit

class MDLangSettingsPopupView: MDSettingsPopupView {
    override func viewDidAppear() {
        super.viewDidAppear()
        
        vOptCollection.scrollToItem(
            at: IndexPath(row: SettingsManager.mangaLangIndex, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
    }
    
    override func itemSize() -> CGSize {
        CGSize(width: 120, height: 88)
    }
    
    override func titleString() -> String {
        "kPrefMangaLang".localized()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        MDLocale.availableRegions.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "langCell", for: indexPath)
        let lang = MDLocale.languages[indexPath.row]
        (cell as? MDLangSettingCollectionCell)?
            .setFlags(lang: lang, regionCode: MDLocale.availableRegions[lang]!)
        return cell
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView, atIndexPath indexPath: IndexPath) {
        SettingsManager.mangaLangIndex = indexPath.row
    }
}
