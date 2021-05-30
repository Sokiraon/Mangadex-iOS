//
//  MDMangaListCell.swift
//  Mangadex
//
//  Created by edz on 2021/5/30.
//

import Foundation
import UIKit

class MDMangaListCell: UITableViewCell {
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
        self.coverImageView = UIImageView.init()
        self.coverImageView.layer.cornerRadius = 10
        self.coverImageView.layer.masksToBounds = true
        contentView.addSubview(self.coverImageView)
        self.coverImageView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
            make.width.equalTo(40)
            make.height.equalTo(60)
        }
        
        self.titleLabel = UILabel.init()
        self.titleLabel.font = UIFont.systemFont(ofSize: 15)
        self.titleLabel.text = "N/A"
        contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.coverImageView).offset(20)
            make.top.equalTo(contentView).offset(10)
        }
        
        self.authorArtistLabel = UILabel.init()
        self.authorArtistLabel.font = UIFont.systemFont(ofSize: 13)
        self.authorArtistLabel.text = "<author> / <artist>"
        contentView.addSubview(self.authorArtistLabel)
        self.authorArtistLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.coverImageView).offset(20)
            make.bottom.equalTo(contentView).offset(-10)
        }
        
        contentView.sizeToFit()
    }
}
