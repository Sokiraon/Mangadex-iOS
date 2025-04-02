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
import ProgressHUD
import OSLog

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
    
    private lazy var refreshHeader = MJRefreshNormalHeader { [unowned self] in
        Task {
            await self.fetchData()
        }
    }
    
    override func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(MDLayout.safeInsetTop)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        setupDataSource()
        refreshHeader.beginRefreshing()
    }
    
    private func fetchData() async {
        do {
            let feedModel = try await Requests.User.getFollowedMangaFeed()
            aggregatedChapters = feedModel.aggregatedByManga
            let mangaIDs = Array(aggregatedChapters.keys)
            let mangaList = try await Requests.Manga.query(params: ["limit": mangaIDs.count, "ids[]": mangaIDs])
            for mangaModel in mangaList.data {
                mangaListModel[mangaModel.id] = mangaModel
            }
            var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, String>()
            snapshot.appendSections([.mangaList])
            snapshot.appendItems(Array(mangaListModel.keys), toSection: .mangaList)
            await dataSource.apply(snapshot, animatingDifferences: true)
            await MainActor.run {
                refreshHeader.endRefreshing()
            }
        } catch {
            Logger().debug("error: \(error.localizedDescription)")
            await MainActor.run {
                ProgressHUD.failed("Network Error")
                refreshHeader.endRefreshing()
            }
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
    }
}

extension FollowedUpdatesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {}
