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
    private var volumesModel: MDMangaVolumesDataModel?
    
    private lazy var vScroll = UIScrollView()
    private lazy var vScrollContent = UIView()
    
    private lazy var vChapters: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (MDLayout.screenWidth - 2*15 - 3*10) / 4, height: 45)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.register(MDMangaChapterCollectionCell.self, forCellWithReuseIdentifier: "chapter")
        view.register(MDMangaChapterSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
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
            .getMangaChaptersById(mangaItem.id) { volumesModel in
                DispatchQueue.main.async {
                    self.volumesModel = volumesModel
                    self.vChapters.reloadData()
                }
            }
    }
}

// MARK: - collectionView
extension MDMangaDetailChapterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (volumesModel != nil) {
            let sectionName = Array(volumesModel!.volumes.keys)[section]
            return volumesModel!.volumes[sectionName]?.chapters?.count ?? 0
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chapter", for: indexPath)
            as! MDMangaChapterCollectionCell
        if (volumesModel != nil) {
            let sectionName = Array(volumesModel!.volumes.keys)[indexPath.section]
            cell.updateWithVolume(sectionName,
                    andChapter: Array(volumesModel!.volumes[sectionName]!.chapters.keys)[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MDMangaChapterCollectionCell
        let vc = MDMangaSlideViewController
            .initWithMangaId(mangaItem.id, volume: cell.volumeName, chapter: cell.chapterName)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        volumesModel?.volumes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! MDMangaChapterSectionHeader
            header.lblSection.text = "kVolume".localized() +
                " \(Array(volumesModel!.volumes.keys)[indexPath.section])"
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 40)
    }
}
