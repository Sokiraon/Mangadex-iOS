//
//  DownloadedChaptersViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/13.
//

import Foundation
import UIKit
import SnapKit

class DownloadsChaptersViewController: BaseViewController {
    private var mangaModel: LocalMangaModel!
    private lazy var vChapters: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let vChapters = UICollectionView(frame: .zero, collectionViewLayout: layout)
        vChapters.delegate = self
        vChapters.dataSource = self
        vChapters.register(
            MangaChapterCollectionCell.self,
            forCellWithReuseIdentifier: "chapter"
        )
        return vChapters
    }()
    
    convenience init(mangaModel: LocalMangaModel) {
        self.init()
        self.mangaModel = mangaModel
    }
    
    override func setupUI() {
        setupNavBar(title: mangaModel.info.attributes.localizedTitle)
        
        view.addSubview(vChapters)
        vChapters.snp.makeConstraints { make in
            make.top.equalTo(appBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

extension DownloadsChaptersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mangaModel.chapters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "chapter",
            for: indexPath
        ) as! MangaChapterCollectionCell
        
        let model = mangaModel.chapters[indexPath.row].info
        cell.chapterView.setContent(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chapterModel = mangaModel.chapters[indexPath.row]
        let vc = DownloadedMangaViewer(
            mangaModel: mangaModel, chapterModel: chapterModel
        )
        navigationController?.pushViewController(vc, animated: true)
    }
}
