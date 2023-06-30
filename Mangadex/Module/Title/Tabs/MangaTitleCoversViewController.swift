//
//  MangaTitleCoversViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/29.
//

import Foundation
import UIKit
import PromiseKit

class MangaTitleCoversViewController: BaseViewController {
    
    var mangaModel: MangaModel!
    
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
    var coverList = [CoverArtModel]()
    
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
        _ = Requests.CoverArt
            .getMangaCoverList(mangaId: mangaModel.id)
            .done { collection in
                self.coverList = collection.data
                var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
                snapshot.appendSections([0])
                snapshot.appendItems(collection.data.map({ $0.id }),
                                     toSection: 0)
                self.dataSource.apply(snapshot)
            }
    }
}
