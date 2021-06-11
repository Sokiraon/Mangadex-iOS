//
//  MDMangaDetailViewController.swift
//  Mangadex
//
//  Created by edz on 2021/6/1.
//

import Foundation
import UIKit

class MDMangaDetailViewController: MDViewController {
    private var mangaCell: MDMangaTableCell!
    
    static func initWithMangaCell(_ cell: MDMangaTableCell) -> MDMangaDetailViewController {
        let vc = self.init()
        vc.mangaCell = cell
        vc.viewTitle = cell.titleLabel.text
        return vc
    }
    
    override func willSetupUI() {
        self.appBar = MDAppBar(title: self.viewTitle)
        self.appBar?.arrowBack.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        self.contentView = UIView()
    }
    
    override func setupUI() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        self.view.addSubview(self.appBar!)
        self.appBar!.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(MDLayout.safeAreaInsets().top)
            make.left.right.equalToSuperview()
        }
        
        self.view.addSubview(self.contentView!)
        self.contentView!.snp.makeConstraints { make in
            make.top.equalTo(self.appBar!.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
