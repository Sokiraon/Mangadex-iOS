//
//  MDMangaTableView.swift
//  Mangadex
//
//  Created by edz on 2021/5/29.
//

import Foundation
import UIKit

struct MangaItem {
    var id: String
    var title: String
    var authorId: String
    var artistId: String
    var coverId: String
}

class MDMangaTableView: UITableView {
    private var mangaList: [MangaItem]
    
    required init?(coder: NSCoder) {
        self.mangaList = []
        super.init(coder: coder)
    }
}
