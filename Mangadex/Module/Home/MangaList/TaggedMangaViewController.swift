//
//  TaggedMangaViewController.swift
//  Mangadex
//
//  Created by John Rion on 2023/3/15.
//

import Foundation
import UIKit
import ProgressHUD
import PromiseKit

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
    
    override func fetchData() {
        Requests.Manga.query(params: queryOptions)
            .done { model in
                self.setData(with: model)
            }
            .catch { error in
                ProgressHUD.showError()
            }
            .finally {
                self.vCollection.mj_header?.endRefreshing()
            }
    }
    
    override func loadMoreData() {
        Requests.Manga.query(params: queryOptions + ["offset": mangaList.count])
            .done { model in
                self.updateData(with: model)
            }
            .catch { error in
                ProgressHUD.showError()
            }
            .finally {
                self.vCollection.mj_header?.endRefreshing()
            }
    }
}
