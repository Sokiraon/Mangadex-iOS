//
//  DownloadsViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/05/11.
//

import Foundation
import UIKit
import MJRefresh

class DownloadsViewController: BaseViewController {
    private lazy var refreshHeader = MJRefreshNormalHeader {
        self.loadData()
    }
    
    private lazy var vCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(DownloadsMangaCollectionCell.self, forCellWithReuseIdentifier: "mangaCell")
        view.contentInset = .cssStyle(5, 10)
        view.mj_header = refreshHeader
        
        return view
    }()
    
    override func setupUI() {
        setupNavBar(title: "kPrefDownloads".localized())
        
        view.insertSubview(vCollection, belowSubview: appBar)
        vCollection.snp.makeConstraints { make in
            make.top.equalTo(appBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        loadData()
    }
    
    private var mangaModels: [LocalMangaModel] = []
    
    private func loadData() {
        guard let mangaModels = DownloadsManager.default.retrieveChapters() else {
            return
        }
        self.mangaModels = mangaModels
        vCollection.reloadData()
        vCollection.mj_header?.endRefreshing()
    }
}

extension DownloadsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mangaModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "mangaCell", for: indexPath
        ) as! DownloadsMangaCollectionCell
        cell.update(mangaModel: mangaModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mangaModel = mangaModels[indexPath.row]
        let vc = DownloadedChaptersViewController(mangaModel: mangaModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}
