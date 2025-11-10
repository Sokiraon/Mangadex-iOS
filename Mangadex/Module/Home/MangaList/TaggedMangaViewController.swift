//
//  TaggedMangaViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/3/15.
//

import Foundation
import UIKit
import ProgressHUD

class TaggedMangaViewController: MangaListViewController {
    private var queryOptions: [String: Any] = [:]
    
    convenience init(title: String?, queryOptions: [String: Any]) {
        self.init()
        self.appBar.title = title
        self.queryOptions = queryOptions
    }
    
    override func setupUI() {
        setupNavBar()
        
        view.insertSubview(vCollection, belowSubview: appBar)
        vCollection.snp.makeConstraints { make in
            make.top.equalTo(appBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func fetchData() async {
        do {
            let model = try await Requests.Manga.query(params: queryOptions)
            self.setData(with: model)
        } catch {
            ProgressHUD.failed()
        }
        await self.vCollection.mj_header?.endRefreshing()
    }
    
    override func loadMoreData() async {
        do {
            let model = try await Requests.Manga.query(params: queryOptions + ["offset": mangaList.count])
            self.updateData(with: model)
        } catch {
            ProgressHUD.failed()
        }
        await self.vCollection.mj_header?.endRefreshing()
    }
}
