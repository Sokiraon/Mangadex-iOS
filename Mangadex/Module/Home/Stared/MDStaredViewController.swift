//
//  MDStaredViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit
import ProgressHUD

class MDStaredViewController: MDViewController {
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
            .getUserFollowedMangas(params: [:]) { data in
                self.mangaList = data
                DispatchQueue.main.async {
                    self.refreshFooter.isHidden = false
                    self.vTable.reloadData()
                    self.vTable.mj_header?.endRefreshing()
                }
            } onError: {
                self.vTable.mj_header?.endRefreshing()
                DispatchQueue.main.async {
                    self.alertForLogin()
                }
            }
    }
    private lazy var refreshFooter = MJRefreshBackNormalFooter() {
        MDHTTPManager.getInstance()
            .getUserFollowedMangas(params: ["offset": self.mangaList.count, "limit": 5]) { data in
                self.mangaList.append(contentsOf: data)
                DispatchQueue.main.async {
                    self.vTable.reloadData()
                    self.vTable.mj_footer?.endRefreshing()
                }
            } onError: {
                self.vTable.mj_footer?.endRefreshing()
                DispatchQueue.main.async {
                    self.alertForLogin()
                }
            }
    }

    private func alertForLogin() {
        let alert = UIAlertController.initWithTitle("kWarning".localized(),
                message: "kLoginRequired".localized(), style: .alert,
                actions:
                AlertViewAction(title: "kOk".localized(), style: .default) { action in
                    let vc = MDPreLoginViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                },
                AlertViewAction(title: "kNo".localized(), style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // initialize
    override func setupUI() {
        view.addSubview(vTable)
        vTable.snp.makeConstraints { make in
            make.top.equalTo(MDLayout.safeAreaInsets(true).top)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func didSetupUI() {
        vTable.mj_header = refreshHeader
        vTable.mj_footer = refreshFooter
        vTable.mj_footer?.isHidden = true
        
        refreshHeader.beginRefreshing()
    }
}

// MARK: - tableView delegate
extension MDStaredViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mangaList.count
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
