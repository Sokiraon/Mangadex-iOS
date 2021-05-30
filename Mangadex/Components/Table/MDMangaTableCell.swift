//
//  MDMangaTableCell.swift
//  Mangadex
//
//  Created by edz on 2021/5/30.
//

import Foundation
import UIKit

class MDMangaTableCell: UITableViewCell {
    var coverImageView: UIImageView!
    var titleLabel: UILabel!
    var authorArtistLabel: UILabel!
    
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
            make.bottom.equalTo(contentView).offset(-10)
            make.width.equalTo(60)
            make.height.equalTo(90)
        }
        
        self.titleLabel = UILabel.init()
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.titleLabel.text = "N/A"
        contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.coverImageView.snp.right).offset(20)
            make.top.equalTo(contentView).offset(15)
        }
        
        self.authorArtistLabel = UILabel.init()
        self.authorArtistLabel.font = UIFont.systemFont(ofSize: 14)
        self.authorArtistLabel.text = "<author> / <artist>"
        contentView.addSubview(self.authorArtistLabel)
        self.authorArtistLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.coverImageView.snp.right).offset(20)
            make.bottom.equalTo(contentView).offset(-15)
        }
        
        contentView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(110)
        }
    }
    
    func setContentWithItem(_ item: MangaItem) {
        self.titleLabel.text = item.title
    }
}
