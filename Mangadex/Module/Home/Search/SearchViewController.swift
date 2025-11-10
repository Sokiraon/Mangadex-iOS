//
//  SearchViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/05.
//

import Foundation
import UIKit
import SnapKit
import MJRefresh

class SearchViewController: BaseViewController {
    private lazy var searchBar = UISearchBar().apply { bar in
        bar.searchBarStyle = .minimal
        bar.delegate = self
    }
    
    private lazy var searchSegment = UISegmentedControl(items: [
        "search.target.manga".localized(),
        "search.target.author".localized(),
        "search.target.group".localized()
    ])
    
    private lazy var refreshHeader = MJRefreshNormalHeader {
        Task {
            await self.performSearch()
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.mj_header = self.refreshHeader
        view.register(MangaListCollectionCell.self, forCellWithReuseIdentifier: "manga")
        view.register(SearchAuthorCollectionCell.self, forCellWithReuseIdentifier: "author")
        view.register(SearchGroupCollectionCell.self, forCellWithReuseIdentifier: "group")
        view.register(CollectionLoaderCell.self, forCellWithReuseIdentifier: "loader")
        return view
    }()
    
    override func setupUI() {
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(MDLayout.safeInsetTop)
            make.left.right.equalToSuperview().inset(4)
        }
        
        view.addSubview(searchSegment)
        searchSegment.selectedSegmentIndex = 0
        searchSegment.addTarget(self, action: #selector(didChangeSearchTarget), for: .valueChanged)
        searchSegment.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.equalToSuperview().inset(12)
        }
        
        view.addSubview(collectionView)
        collectionView.contentInset = .cssStyle(0, 12, 8)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchSegment.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        setupDataSource()
    }
    
    private var searchTask: Task<Void, Never>?
    
    private func performSearch() async {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        let selectedIndex = searchSegment.selectedSegmentIndex
        
        var snapshot = NSDiffableDataSourceSnapshot<CollectionSection, String>()
        snapshot.appendSections([.manga, .author, .group, .loader])
        
        do {
            switch selectedIndex {
            case 0:
                let mangaCollection = try await Requests.Manga.query(params: ["title": searchText])
                self.mangaList = mangaCollection.data
                snapshot.appendItems(mangaCollection.data.map { $0.id }, toSection: .manga)
                if mangaCollection.limit < mangaCollection.total {
                    snapshot.appendItems([self.collectionLoaderIdentifier], toSection: .loader)
                }
            case 1:
                let authorCollection = try await Requests.Author.query(params: ["name": searchText])
                self.authorList = authorCollection.data
                snapshot.appendItems(authorCollection.data.map { $0.id }, toSection: .author)
                if authorCollection.limit < authorCollection.total {
                    snapshot.appendItems([self.collectionLoaderIdentifier], toSection: .loader)
                }
            case 2:
                let groupCollection = try await Requests.Group.query(params: ["name": searchText])
                self.groupList = groupCollection.data
                snapshot.appendItems(groupCollection.data.map { $0.id }, toSection: .group)
                if groupCollection.limit < groupCollection.total {
                    snapshot.appendItems([self.collectionLoaderIdentifier], toSection: .loader)
                }
            default:
                break
            }
            
            await self.dataSource.apply(snapshot, animatingDifferences: true)
        } catch {
            // Optionally show an error HUD/toast here
        }
        await self.refreshHeader.endRefreshing()
    }
    
    @objc private func didChangeSearchTarget() {
        searchBar.resignFirstResponder()
        if !searchBar.text.isBlank {
            Task {
                await self.performSearch()
            }
        }
    }
    
    @objc private func searchForMore() {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        let selectedIndex = searchSegment.selectedSegmentIndex
        
        Task {
            var snapshot = self.dataSource.snapshot()
            do {
                switch selectedIndex {
                case 0:
                    let mangaListModel = try await Requests.Manga.query(params: [
                        "title": searchText,
                        "offset": self.mangaList.count
                    ])
                    self.mangaList.append(contentsOf: mangaListModel.data)
                    snapshot.appendItems(mangaListModel.data.map { $0.id }, toSection: .manga)
                    if self.mangaList.count == mangaListModel.total {
                        snapshot.deleteItems([self.collectionLoaderIdentifier])
                    }
                case 1:
                    let authorCollection = try await Requests.Author.query(params: [
                        "name": searchText,
                        "offset": self.authorList.count
                    ])
                    self.authorList.append(contentsOf: authorCollection.data)
                    snapshot.appendItems(authorCollection.data.map { $0.id }, toSection: .author)
                    if self.authorList.count == authorCollection.total {
                        snapshot.deleteItems([self.collectionLoaderIdentifier])
                    }
                case 2:
                    let groupCollection = try await Requests.Group.query(params: [
                        "name": searchText,
                        "offset": self.groupList.count
                    ])
                    self.groupList.append(contentsOf: groupCollection.data)
                    snapshot.appendItems(groupCollection.data.map { $0.id }, toSection: .group)
                    if self.groupList.count == groupCollection.total {
                        snapshot.deleteItems([self.collectionLoaderIdentifier])
                    }
                default:
                    break
                }
                
                await self.dataSource.apply(snapshot, animatingDifferences: true)
            } catch {
                // Optionally handle pagination fetch error
            }
        }
    }
    
    enum CollectionSection: Int {
        case manga, author, group
        case loader
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<CollectionSection, String>!
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in
            guard let section = CollectionSection(rawValue: indexPath.section) else {
                return nil
            }
            switch section {
            case .manga:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "manga", for: indexPath)
                    as? MangaListCollectionCell
                cell?.setContent(mangaModel: self.mangaList[indexPath.item])
                return cell
            case .author:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "author", for: indexPath)
                    as? SearchAuthorCollectionCell
                cell?.setContent(authorModel: self.authorList[indexPath.item])
                return cell
            case .group:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "group", for: indexPath)
                    as? SearchGroupCollectionCell
                cell?.setContent(groupModel: self.groupList[indexPath.item])
                return cell
            case .loader:
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: "loader", for: indexPath)
            }
        }
    }
    
    private let collectionLoaderIdentifier = "0"
    
    private var mangaList = [MangaModel]()
    private var authorList = [AuthorModel]()
    private var groupList = [GroupModel]()
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Clear collectionView items
            var snapshot = dataSource.snapshot()
            snapshot.deleteAllItems()
            dataSource.apply(snapshot, animatingDifferences: true)
            searchTask?.cancel()
            return
        }
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(for: .milliseconds(500))
                try Task.checkCancellation()
                await self.performSearch()
            } catch {
                // Swallow — a newer keystroke will schedule another Task
            }
        }
    }
}

fileprivate let collectionCellWidth = MDLayout.screenWidth - 2 * 12

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let section = CollectionSection(rawValue: indexPath.section) else {
            return .zero
        }
        switch section {
        case .manga:
            return .init(width: collectionCellWidth, height: 105)
        case .author:
            return .init(width: collectionCellWidth, height: 40)
        case .group:
            return .init(width: collectionCellWidth, height: 64)
        case .loader:
            return .init(width: collectionCellWidth, height: 50)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if indexPath.section == CollectionSection.loader.rawValue {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(searchForMore), with: nil, afterDelay: 0.5, inModes: [.default])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? Highlightable {
            cell.didHighlighted()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = CollectionSection(rawValue: indexPath.section) else {
            return
        }
        searchBar.endEditing(true)
        switch section {
        case .manga:
            let mangaModel = mangaList[indexPath.item]
            let vc = MangaTitleViewController(mangaModel: mangaModel)
            navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? Highlightable {
            cell.didUnHighlighted()
        }
    }
}
