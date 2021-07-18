//
//  MDMangaDetailChapterViewController.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/27.
//

import Foundation
import UIKit

class MDMangaDetailChapterViewController: MDViewController {
    // MARK: - properties
    private var mangaItem: MangaItem!
    private var chapterModels: [MDMangaChapterDataModel]?
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
            .getChaptersByMangaId(mangaItem.id, offset: 0, locale: "en", order: .ASC) { models, total in
                DispatchQueue.main.async {
                    self.chapterModels = models
                    self.totalChapters = total
                    self.vChapters.reloadData()
                }
            }
    }
}

// MARK: - collectionView
extension MDMangaDetailChapterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        chapterModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chapter", for: indexPath)
            as! MDMangaChapterCollectionCell
        if (chapterModels != nil) {
            let attrs = chapterModels![indexPath.row].data.attributes!
            cell.updateWithVolume(attrs.volume, andChapter: attrs.chapter)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MDMangaSlideViewController
                .initWithChapterData(chapterModels![indexPath.row], currentIndex: indexPath.row)
        { [self] index -> MDMangaChapterDataModel? in
            if (index < chapterModels!.count) {
                return chapterModels![index + 1]
            } else {
                return nil
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 40)
    }
}
