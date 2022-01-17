//
//  MDMangaDetailChapterViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

import Foundation
import UIKit
import SwiftEventBus
import XLPagerTabStrip

class MDMangaDetailChapterViewController: MDViewController {
    // MARK: - properties
    private var mangaItem: MangaItem!
    private var chapterModels = [MDMangaChapterInfoModel]()
    private var totalChapters: Int!
    
    private lazy var vChapters: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (MDLayout.screenWidth - 2 * 15 - 3 * 10) / 4, height: 45)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.contentInset = UIEdgeInsets(value: "0 15 10")
        view.register(MDMangaChapterCollectionCell.self, forCellWithReuseIdentifier: "chapter")
        return view
    }()
    
    // MARK: - initialize
    func updateWithMangaItem(_ item: MangaItem) {
        mangaItem = item
    }
    
    override func setupUI() {
        view.addSubview(vChapters)
        vChapters.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        MDHTTPManager.getInstance()
                     .getChaptersByMangaId(
                         mangaItem.id,
                         offset: 0,
                         locale: MDLocale.currentMangaLanguage,
                         order: .ASC
                     ) { models, total in
                         DispatchQueue.main.async {
                             self.chapterModels = models
                             self.totalChapters = total
                             self.vChapters.reloadData()
                
                             SwiftEventBus.onMainThread(self, name: "openChapter") { result in
                                 if (self.lastViewedChapterIndex == nil) {
                                     self.lastViewedChapterIndex = IndexPath(row: 0, section: 0)
                                 }
                                 self.openSliderForIndexPath(self.lastViewedChapterIndex!)
                             }
                         }
                     }
    }
    
    private var lastViewedChapterId: String?
    private var lastViewedChapterIndex: IndexPath?
    
    override func doOnAppear() {
        lastViewedChapterId = MDMangaProgressManager.retrieveProgress(forMangaId: mangaItem.id)
    }
    
    private func openSliderForIndexPath(_ path: IndexPath) {
        let vc = MDMangaSlideViewController(
            chapterInfo: chapterModels[path.row],
            currentIndex: path.row,
            requirePrevAction: { index in
                return index > 0 ? self.chapterModels[index - 1] : nil
            },
            requireNextAction: { index in
                return index < self.chapterModels.count - 1 ? self.chapterModels[index + 1] : nil
            },
            enterPageAction: { chapterId in
                MDMangaProgressManager.saveProgress(forMangaId: self.mangaItem.id, chapterId: chapterId)
            },
            leavePageAction: {
                self.vChapters.reloadData()
            }
        )
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - collectionView delegate
extension MDMangaDetailChapterViewController: UICollectionViewDelegate,
                                              UICollectionViewDataSource,
                                              UICollectionViewDelegateFlowLayout,
                                              IndicatorInfoProvider {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        chapterModels.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "chapter",
            for: indexPath
        )
            as! MDMangaChapterCollectionCell
        
        let model = chapterModels[indexPath.row]
        let lastViewed = model.id == lastViewedChapterId
        cell.set(
            volume: model.attributes.volume,
            chapter: model.attributes.chapter,
            lastViewed: lastViewed
        )
        if lastViewed {
            lastViewedChapterIndex = indexPath
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openSliderForIndexPath(indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 40)
    }
    
    public func indicatorInfo(
        for pagerTabStripController: PagerTabStripViewController
    ) -> IndicatorInfo {
        IndicatorInfo(title: "kMangaDetailChapters".localized())
    }
}
