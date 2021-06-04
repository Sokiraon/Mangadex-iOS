//
//  MDMangaTableCell.swift
//  Mangadex
//
//  Created by edz on 2021/5/30.
//

import Foundation
import UIKit
import Kingfisher

class MDMangaTableCell: UITableViewCell {
    var coverImageView: UIImageView!
    var titleLabel: UILabel!
    var authorLabel: UILabel!
    var artistLabel: UILabel!
    var hasInitialized = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
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
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(contentView).offset(10)
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
            make.top.equalTo(contentView).offset(15)
            make.right.equalToSuperview().inset(10)
        }
        
        self.authorLabel = UILabel.init()
        self.authorLabel.font = UIFont.systemFont(ofSize: 15)
        self.authorLabel.text = "Author: "
        self.authorLabel.adjustsFontSizeToFitWidth = true
        self.authorLabel.minimumScaleFactor = (15 - 2) / 15
        contentView.addSubview(self.authorLabel)
        self.authorLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.coverImageView.snp.right).offset(20)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.right.equalToSuperview().inset(10)
        }
        
        self.artistLabel = UILabel.init()
        self.artistLabel.font = UIFont.systemFont(ofSize: 15)
        self.artistLabel.text = "Artist: "
        self.artistLabel.adjustsFontSizeToFitWidth = true
        self.artistLabel.minimumScaleFactor = (15 - 2) / 15
        contentView.addSubview(self.artistLabel)
        self.artistLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.coverImageView.snp.right).offset(20)
            make.top.equalTo(self.authorLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().inset(10)
        }
        
        contentView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(110)
        }
    }
    
    func setContentWithItem(_ item: MangaItem) {
        if (!self.hasInitialized) {
            self.titleLabel.text = item.title
            self.coverImageView.kf.setImage(with: MDRemoteImage.getCoverUrlById(item.coverId, forManga: item.id),
                                            placeholder: UIImage(named: "manga_cover_default"))
            self.authorLabel.text = self.authorLabel.text?.appending(MDRemoteText.getAuthorNameById(item.authorId))
            self.artistLabel.text = self.artistLabel.text?.appending(MDRemoteText.getAuthorNameById(item.artistId))
            self.hasInitialized = true
        }
    }
}
