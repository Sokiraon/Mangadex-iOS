//
//  MangaTitleCoversViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/29.
//

import Foundation
import UIKit
import Agrume

class MangaTitleCoversViewController: BaseViewController {
    
    let cellWidth = (MDLayout.screenWidth - 16 * 3) / 2
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(cellWidth),
                                              heightDimension: .absolute(240))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(240))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.interItemSpacing = .fixed(16)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    lazy var collectionView = ChildCollectionView(
        frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    override func setupUI() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = .cssStyle(8, 0, MDLayout.adjustedSafeInsetBottom)
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
        }
    }
    
    override func didSetupUI() {
        setupDataSource()
        fetchData()
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    var mangaModel: MangaModel!
    var coverList = [CoverArtModel]()
    var coverURLs = [URL]()
    
    func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MangaTitleCoverCell, String>
        { cell, indexPath, itemIdentifier in
            cell.setContent(with: self.mangaModel,
                            coverModel: self.coverList[indexPath.item])
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView)
        { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }
    
    func fetchData() {
        Task { @MainActor in
            let collection = try await Requests.CoverArt.getMangaCoverList(mangaId: mangaModel.id)
            self.coverList = collection.data
            self.coverURLs = collection.data.compactMap {
                $0.getOriginalUrl(mangaId: self.mangaModel.id)
            }
            var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
            snapshot.appendSections([0])
            snapshot.appendItems(collection.data.map({ $0.id }),
                                 toSection: 0)
            await self.dataSource.apply(snapshot)
        }
    }
}

extension MangaTitleCoversViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let agrume = Agrume(urls: coverURLs, startIndex: indexPath.row)
        agrume.didScroll = { [unowned self] index in
            self.collectionView.scrollToItem(
                at: IndexPath(row: index, section: 0),
                at: .top,
                animated: false)
        }
        agrume.show(from: self)
    }
}
