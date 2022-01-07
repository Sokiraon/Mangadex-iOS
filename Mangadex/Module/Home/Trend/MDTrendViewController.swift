//
//  MDTrendViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit
import ProgressHUD
import SkeletonView

class MDTrendViewController: MDViewController {
    // initialize
    override func setupUI() {
        view.addSubview(vTable)
        vTable.snp.makeConstraints { make in
            make.top.equalTo(MDLayout.safeInsetTop)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        vTable.mj_header = refreshHeader
        vTable.mj_footer = refreshFooter
        vTable.mj_footer?.isHidden = true
        
        refreshHeader.beginRefreshing()
    }
    
    // MARK: - properties
    private lazy var vTable: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var mangaList = [MangaItem]()
    
    private lazy var refreshHeader = MJRefreshNormalHeader {
        MDHTTPManager.getInstance()
                .getMangaListWithParams([:]) { data in
                    self.mangaList = data
                    DispatchQueue.main.async {
                        self.refreshFooter.isHidden = false
                        self.vTable.reloadData()
                        self.vTable.mj_header?.endRefreshing()
                    }
                } onError: {
                    DispatchQueue.main.async {
                        ProgressHUD.showError()
                    }
                    self.vTable.mj_header?.endRefreshing()
                }
    }
    private lazy var refreshFooter = MJRefreshBackNormalFooter {
        MDHTTPManager.getInstance()
                .getMangaListWithParams(["offset": self.mangaList.count, "limit": 5]) { data in
                    self.mangaList.append(contentsOf: data)
                    DispatchQueue.main.async {
                        self.vTable.reloadData()
                        self.vTable.mj_footer?.endRefreshing()
                    }
                } onError: {
                    DispatchQueue.main.async {
                        ProgressHUD.showError()
                    }
                    self.vTable.mj_footer?.endRefreshing()
                }
    }
}

// MARK: - tableView delegate
extension MDTrendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mangaList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = mangaList[indexPath.row].id
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = MDMangaTableCell(style: .default, reuseIdentifier: identifier)
        }
        (cell as! MDMangaTableCell).setContentWithItem(mangaList[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        110.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        let vc = MDMangaDetailViewController
                .initWithMangaItem(mangaList[indexPath.row],
                                   title: (cell as! MDMangaTableCell).titleLabel.text!)
        navigationController?.pushViewController(vc, animated: true)
    }
}
