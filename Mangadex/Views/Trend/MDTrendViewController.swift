//
//  MDTrendViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit

class MDTrendViewController: UIViewController {
    private var tableView: UITableView!
    private var mangaList: [MangaItem] = [
        MangaItem(id: "32d76d19-8a05-4db0-9fc2-e0b0648fe9d0", title: "Solo Leveling", authorId: "820b13ef-dc7d-42b1-999a-65393b8b4040", artistId: "86f43f7f-7f32-4ecb-8dd9-7cd2ae16932b", coverId: "b6c7ce9c-e671-4f26-90b0-e592188e9cd6")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(MDMangaTableCell.self, forCellReuseIdentifier: "mangaCell")
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        let queue = DispatchQueue(label: "manga")
        queue.async {
            self.mangaList = MDRemoteText.getMangaList(offset: 0)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension MDTrendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mangaList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "mangaCell")
        if (cell == nil) {
            cell = MDMangaTableCell.init(style: .default, reuseIdentifier: "mangaCell")
        }
        if (!tableView.isDragging && !tableView.isDecelerating) {
            (cell as! MDMangaTableCell).setContentWithItem(mangaList[indexPath.row])
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let vc = MDMangaDetailViewController.initWithMangaCell(cell as! MDMangaTableCell)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
