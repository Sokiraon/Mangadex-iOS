//
//  MDMangaDetailChapterViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

import Foundation
import UIKit
import SwiftEventBus

class MDMangaDetailChapterViewController: MDViewController {
    // MARK: - properties
    private var mangaItem: MangaItem!
    private var chapterModels = [MDMangaChapterInfoModel]()
    private var totalChapters: Int!
    
    private lazy var vScroll = UIScrollView()
    private lazy var vScrollContent = UIView()
    
    private lazy var vChapters: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (MDLayout.screenWidth - 2*15 - 3*10) / 4, height: 45)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.register(MDMangaChapterCollectionCell.self, forCellWithReuseIdentifier: "chapter")
        return view
    }()
    
    // MARK: - initialize
    func updateWithMangaItem(_ item: MangaItem) {
        mangaItem = item
    }
    
    override func setupUI() {
        view.addSubview(vScroll)
        vScroll.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(vScrollContent)
        vScrollContent.snp.makeConstraints { make in
            make.edges.equalTo(self.vScroll)
            make.width.equalTo(MDLayout.screenWidth)
        }
        
        vScrollContent.addSubview(vChapters)
        vChapters.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        MDHTTPManager.getInstance()
            .getChaptersByMangaId(mangaItem.id, offset: 0, locale: MDLocale.currentMangaLanguage, order: .ASC) { models, total in
                DispatchQueue.main.async {
                    self.chapterModels = models
                    self.totalChapters = total
                    self.vChapters.reloadData()
                    
                    SwiftEventBus.onMainThread(self, name: "openChapter") { result in
                        if (self.lastReadIndex == nil) {
                            self.lastReadIndex = IndexPath(row: 0, section: 0)
                        }
                        self.openSliderForIndexPath(self.lastReadIndex!)
                    }
                }
            }
    }
    
    private var progress: String?
    private var lastReadIndex: IndexPath?
    
    override func doOnAppear() {
        progress = MDMangaProgressManager.retrieveProgress(forMangaId: mangaItem.id)
    }
    
    private func openSliderForIndexPath(_ path: IndexPath) {
        let vc = MDMangaSlideViewController.initWithChapterData(
            chapterModels[path.row],
            currentIndex: path.row,
            requirePrevAction: { index -> MDMangaChapterInfoModel? in
                if (index > 0) {
                    return self.chapterModels[index - 1]
                } else {
                    return nil
                }
            },
            requireNextAction: { index -> MDMangaChapterInfoModel? in
                if (index < self.chapterModels.count - 1) {
                    return self.chapterModels[index + 1]
                } else {
                    return nil
                }
            },
            leavePageAction: { chapter in
                MDMangaProgressManager.saveProgress(chapter, forMangaId: self.mangaItem.id)
                self.vChapters.reloadData()
            }
        )
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - collectionView
extension MDMangaDetailChapterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        chapterModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chapter", for: indexPath)
            as! MDMangaChapterCollectionCell
        
        let attrs = chapterModels[indexPath.row].attributes!
        cell.setWithVolume(attrs.volume, andChapter: attrs.chapter, withProgress: progress)
        if (attrs.chapter == progress) {
            lastReadIndex = indexPath
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openSliderForIndexPath(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 40)
    }
}
