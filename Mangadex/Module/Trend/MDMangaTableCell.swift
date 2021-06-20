//
//  MDMangaTableCell.swift
//  Mangadex
//
//  Created by edz on 2021/5/30.
//

import Foundation
import UIKit
import Kingfisher

struct MangaItem {
    var id: String
    var title: String
    var authorId: String
    var artistId: String
    var coverId: String
}

class MDMangaTableCell: UITableViewCell {
    // MARK: - properties
    var coverImageView: UIImageView!
    var titleLabel: UILabel!
    var authorLabel: UILabel!
    var artistLabel: UILabel!
    var hasInitialized = false
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func initCell() {
        self.coverImageView = UIImageView.init(image: UIImage(named: "manga_cover_default"))
        self.coverImageView.layer.cornerRadius = 5
        self.coverImageView.layer.masksToBounds = true
        contentView.addSubview(self.coverImageView)
        self.coverImageView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(60)
            make.height.equalTo(90)
        }
        
        self.titleLabel = UILabel.init()
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.titleLabel.text = "N/A"
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.minimumScaleFactor = (18 - 2) / 18
        contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.coverImageView.snp.right).offset(20)
            make.top.equalToSuperview().inset(15)
            make.right.equalToSuperview().inset(10)
        }
        
        self.authorLabel = UILabel.init()
        self.authorLabel.font = UIFont.systemFont(ofSize: 15)
        self.authorLabel.text = "Author: Unknown"
        self.authorLabel.adjustsFontSizeToFitWidth = true
        self.authorLabel.minimumScaleFactor = (15 - 2) / 15
        contentView.addSubview(self.authorLabel)
        self.authorLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.right.equalToSuperview().inset(10)
        }
        
        self.artistLabel = UILabel.init()
        self.artistLabel.font = UIFont.systemFont(ofSize: 15)
        self.artistLabel.text = "Artist: Unknown"
        self.artistLabel.adjustsFontSizeToFitWidth = true
        self.artistLabel.minimumScaleFactor = (15 - 2) / 15
        contentView.addSubview(self.artistLabel)
        self.artistLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.titleLabel)
            make.top.equalTo(self.authorLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().inset(10)
        }
    }
    
    func setContentWithItem(_ item: MangaItem) {
        self.titleLabel.text = item.title
        MDHTTPManager()
            .getMangaCoverUrlById(item.coverId, forManga: item.id) { url in
                DispatchQueue.main.async {
                    self.coverImageView.kf.setImage(with: url, placeholder: UIImage(named: "manga_cover_default"))
                    self.layer.display()
                }
            }
        MDHTTPManager()
            .getAuthorNameById(item.authorId) { author in
                DispatchQueue.main.async {
                    self.authorLabel.text = "Author: \(author)"
                    self.layer.display()
                }
            }
        MDHTTPManager()
            .getAuthorNameById(item.artistId) { artist in
                DispatchQueue.main.async {
                    self.artistLabel.text = "Artist: \(artist)"
                    self.layer.display()
                }
            }
    }
}
