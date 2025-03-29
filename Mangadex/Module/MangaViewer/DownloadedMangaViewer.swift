//
//  DownloadedMangaViewer.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/15.
//

import Foundation
import UIKit
import SnapKit
import MJRefresh

class DownloadedMangaViewer: MangaViewer {
    
    // MARK: - Lifecycle Methods
    convenience init(
        mangaModel: LocalMangaModel,
        chapterModel: LocalChapterModel
    ) {
        self.init()
        self.mangaModel = mangaModel
        self.chapterModel = chapterModel
        self.pageURLs = self.chapterModel.pageURLs
        self.vSlider.maximumValue = Float(self.pageURLs.count - 1)
    }
    
    override func setupUI() {
        super.setupUI()
        appBar.title = chapterModel.info.attributes.chapterName
        
        vBottomControl.addSubview(vSlider)
        vSlider.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(MDLayout.adjustedSafeInsetBottom)
        }
        
        vBottomControl.addSubview(btnPrev)
        btnPrev.snp.makeConstraints { make in
            make.centerY.equalTo(vSlider)
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(vSlider.snp.left).offset(-16)
        }
        
        vBottomControl.addSubview(btnNext)
        btnNext.snp.makeConstraints { make in
            make.centerY.equalTo(vSlider)
            make.right.equalToSuperview().inset(16)
            make.left.equalTo(vSlider.snp.right).offset(16)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleControlArea()
    }
    
    // MARK: - Properties
    private var mangaModel: LocalMangaModel!
    private var chapterModel: LocalChapterModel!
    
    private lazy var currentIndex: Int = {
        mangaModel.chapters.firstIndex { model in
            model == self.chapterModel
        }!
    }()
    
    override func getPreviousViewController() -> MangaViewer? {
        guard let nextChapterModel = mangaModel.chapters.get(currentIndex - 1) else {
            return nil
        }
        return DownloadedMangaViewer(
            mangaModel: mangaModel, chapterModel: nextChapterModel
        )
    }
    
    override func getNextViewController() -> MangaViewer? {
        guard let nextChapterModel = mangaModel.chapters.get(currentIndex + 1) else {
            return nil
        }
        return DownloadedMangaViewer(
            mangaModel: mangaModel, chapterModel: nextChapterModel
        )
    }
}
