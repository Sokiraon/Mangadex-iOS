//
//  FollowedUpdatesViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/27.
//

import Foundation
import UIKit
import PromiseKit
import MJRefresh

class FollowedUpdatesViewController: BaseViewController {
    
    private var aggregatedChapters: [String: [ChapterModel]] = [:]
    private var mangaListModel: [String: MangaModel] = [:]
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.register(FollowedUpdatesCollectionCell.self, forCellWithReuseIdentifier: "cell")
        view.contentInset = .cssStyle(5, 10, 10)
        view.mj_header = refreshHeader
        return view
    }()
    
    private lazy var refreshHeader = MJRefreshNormalHeader {
        self.fetchData()
    }
    
    override func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(MDLayout.safeInsetTop)
            make.left.right.bottom.equalToSuperview()
        }
        
        refreshHeader.beginRefreshing()
    }
    
    private func fetchData() {
        firstly {
            Requests.User.getFollowedMangaFeed()
        }.then { feedModel in
            self.aggregatedChapters = feedModel.aggregated
            let mangaIds = Array(feedModel.aggregated.keys)
            return Requests.Manga.query(
                params: ["limit": mangaIds.count, "ids[]": mangaIds])
        }.done { mangaList in
            for mangaModel in mangaList.data {
                self.mangaListModel[mangaModel.id] = mangaModel
            }
            self.setupDataSource()
        }.catch { error in
            
        }.finally {
            self.refreshHeader.endRefreshing()
        }
    }
    
    enum CollectionSection {
        case mangaList
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<CollectionSection, String>!
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView)
        { collectionView, indexPath, itemIdentifier in
            guard let mangaModel = self.mangaListModel[itemIdentifier],
                  let chapters = self.aggregatedChapters[itemIdentifier]
                   else {
                return nil
            }
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "cell", for: indexPath)
            as? FollowedUpdatesCollectionCell
            cell?.setContent(mangaModel: mangaModel, chapters: chapters)
            return cell
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, String>()
        snapshot.appendSections([.mangaList])
        snapshot.appendItems(Array(mangaListModel.keys), toSection: .mangaList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension FollowedUpdatesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
}
