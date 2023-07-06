//
//  MangaTitleChaptersViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/27.
//

import Foundation
import UIKit
import SnapKit
import MJRefresh
import PromiseKit

class MangaTitleChaptersViewController: BaseViewController {
    
    lazy var refreshHeader = MJRefreshNormalHeader {
        self.fetchChapters()
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    lazy var collectionView = ChildCollectionView(
        frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    override func setupUI() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = .cssStyle(8, 0, MDLayout.adjustedSafeInsetBottom)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.left.right.bottom.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
        }
        
        setupDataSource()
    }
    
    enum CollectionSection: Int {
        case chapters
        case loader
    }
    
    var dataSource: UICollectionViewDiffableDataSource<CollectionSection, String>!
    
    func setupDataSource() {
        let chapterCellRegistration = UICollectionView.CellRegistration<MangaChapterCollectionCell, String>
        { cell, indexPath, itemIdentifier in
            let chapterModel = self.chapterModels[indexPath.item]
            cell.chapterView.setContent(with: chapterModel)
        }
        
        let loaderCellRegistration = UICollectionView.CellRegistration<CollectionLoaderCell, String>
        { cell, indexPath, itemIdentifier in
            
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView)
        { collectionView, indexPath, itemIdentifier in
            switch CollectionSection(rawValue: indexPath.section)! {
            case .chapters:
                return collectionView.dequeueConfiguredReusableCell(
                    using: chapterCellRegistration, for: indexPath, item: itemIdentifier)
            case .loader:
                return collectionView.dequeueConfiguredReusableCell(
                    using: loaderCellRegistration, for: indexPath, item: itemIdentifier)
            }
        }
        
        fetchChapters()
    }
    
    var chapterModels = [ChapterModel]()
    var totalChapters = 0
    
    var mangaModel: MangaModel!
    let loadingCellIdentifier = UUID().uuidString
    
    func fetchChapters() {
        _ = Requests.Chapter
            .getMangaFeed(mangaId: mangaModel.id, offset: 0)
            .done { chapters in
                self.chapterModels = chapters.data
                self.totalChapters = chapters.total
                
                var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, String>()
                snapshot.appendSections([.chapters, .loader])
                snapshot.appendItems(chapters.data.map({ chapterModel in
                    chapterModel.id
                }), toSection: .chapters)
                if chapters.data.count < chapters.total {
                    snapshot.appendItems([self.loadingCellIdentifier],
                                         toSection: .loader)
                }
                self.dataSource.apply(snapshot)
            }
    }
    
    func loadMoreChapters() {
        _ = Requests.Chapter
            .getMangaFeed(mangaId: mangaModel.id, offset: chapterModels.count)
            .done { chapters in
                self.chapterModels.append(contentsOf: chapters.data)
                self.totalChapters = chapters.total
                var snapshot = self.dataSource.snapshot()
                snapshot.appendItems(chapters.data.map({ chapterModel in
                    chapterModel.id
                }), toSection: .chapters)
                if self.chapterModels.count >= chapters.total {
                    snapshot.deleteItems([self.loadingCellIdentifier])
                }
                self.dataSource.apply(snapshot)
            }
    }
    
    func viewChapter(at indexPath: IndexPath) {
        let chapterModel = chapterModels[indexPath.item]
        let vc = OnlineMangaViewer(mangaModel: mangaModel, chapterId: chapterModel.id)
        navigationController?.pushViewController(vc, animated: true)
    }
}
