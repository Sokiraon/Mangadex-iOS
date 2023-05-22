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
        super.setupUI()
        
        vTopArea.theme_backgroundColor = UIColor.themePrimaryPicker
        
        vTopArea.addSubview(appBar)
        appBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(MDLayout.safeInsetTop)
            make.height.equalTo(44)
        }
    }
    
    override func fetchData() {
        MDRequests.Manga.query(params: queryOptions)
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
        MDRequests.Manga.query(params: queryOptions + ["offset": mangaList.count])
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
