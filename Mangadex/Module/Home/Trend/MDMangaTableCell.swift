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
    // MARK: - properties
    var coverImageView: UIImageView = {
        let view = UIImageView.init(imageNamed: "manga_cover_default")
        view.layer.cornerRadius = 5
        return view
    }()
    
    var titleLabel = UILabel.initWithText("N/A", ofFontWeight: .medium, andSize: 18)
    var authorLabel = UILabel.initWithText("kAuthorUnknown".localized(), ofFontWeight: .regular, andSize: 15)
    var artistLabel = UILabel.initWithText("kArtistUnknown".localized(), ofFontWeight: .regular, andSize: 15)
    
    // MARK: - initialize
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func initCell() {
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(60)
            make.height.equalTo(90)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(coverImageView.snp.right).offset(20)
            make.top.equalToSuperview().inset(15)
            make.right.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.right.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(artistLabel)
        artistLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(titleLabel)
            make.top.equalTo(authorLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().inset(10)
        }
    }
    
    // MARK: - methods
    func setContentWithItem(_ item: MangaItem) {
        titleLabel.text = item.title
        MDHTTPManager()
            .getMangaCoverUrlById(item.coverId, forManga: item.id) { url in
                DispatchQueue.main.async {
                    self.coverImageView.kf.setImage(with: url, placeholder: UIImage(named: "manga_cover_default"))
                }
            }
        MDHTTPManager()
            .getAuthorNameById(item.authorId) { author in
                DispatchQueue.main.async {
                    self.authorLabel.text = "\("kAuthor".localized()) \(author)"
                }
            }
        MDHTTPManager()
            .getAuthorNameById(item.artistId) { artist in
                DispatchQueue.main.async {
                    self.artistLabel.text = "\("kArtist".localized()) \(artist)"
                }
            }
    }
}
