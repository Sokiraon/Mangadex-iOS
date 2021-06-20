//
//  MDTrendViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit
import ProgressHUD
import MJRefresh

class MDTrendViewController: MDViewController {
    
    override func setupUI() {
        self.view.addSubview(self.vTable)
        self.vTable.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }
    
    override func didSetupUI() {
        self.vTable.mj_header = refreshHeader
        self.vTable.mj_footer = refreshFooter
        self.vTable.mj_footer?.isHidden = true
        
        refreshHeader.beginRefreshing()
    }
    
    // MARK: - properties
    private lazy var vTable: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var mangaList: [MangaItem] = []
    
    private lazy var refreshHeader = MJRefreshNormalHeader() {
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
    private lazy var refreshFooter = MJRefreshBackNormalFooter() {
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
    
    private lazy var queue = DispatchQueue(label: "cellQueue")
    
    // MARK: - actions
}

// MARK: - tableView delegate
extension MDTrendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mangaList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = mangaList[indexPath.row].id
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = MDMangaTableCell(style: .default, reuseIdentifier: identifier)
        }
        
        if (!tableView.isDragging) {
            (cell as! MDMangaTableCell).setContentWithItem(self.mangaList[indexPath.row])
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        let vc = MDMangaDetailViewController
            .initWithMangaItem(mangaList[indexPath.row],
                               title: (cell as! MDMangaTableCell).titleLabel.text!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
