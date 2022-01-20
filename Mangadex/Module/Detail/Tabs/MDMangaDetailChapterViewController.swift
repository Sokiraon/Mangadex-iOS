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
    
    private var lastViewedChapterId: String?
    private var lastViewedChapterIndex: IndexPath?
    
    private lazy var vChapters: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        // four chapter cells per row
        layout.itemSize = CGSize(width: (MDLayout.screenWidth - 2 * 15 - 3 * 10) / 4, height: 45)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.contentInset = .cssStyle(-20, 15, 10)
        view.showsVerticalScrollIndicator = false
        view.register(MDMangaChapterCollectionCell.self, forCellWithReuseIdentifier: "chapter")
        return view
    }()
    
    private lazy var vProgress: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        view.theme_color = UIColor.theme_primaryColor
        return view
    }()
    
    // MARK: - initialize
    convenience init(mangaItem item: MangaItem) {
        self.init()
        mangaItem = item
    }
    
    override func setupUI() {
        view.addSubview(vChapters)
        vChapters.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.insertSubview(vProgress, aboveSubview: vChapters)
        vProgress.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(48)
        }
    }
    
    override func didSetupUI() {
        lastViewedChapterId = MDMangaProgressManager.retrieveProgress(forMangaId: mangaItem.id)
        
        vProgress.startAnimating()
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
                    self.vProgress.stopAnimating()
                    
                    SwiftEventBus.onMainThread(self, name: "openChapter") { result in
                        if (self.lastViewedChapterIndex == nil) {
                            self.lastViewedChapterIndex = IndexPath(row: 0, section: 0)
                        }
                        self.openSliderForIndexPath(self.lastViewedChapterIndex!)
                    }
                }
            }
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
