//
//  MDMangaTableCell.swift
//  Mangadex
//
//  Created by edz on 2021/5/30.
//

import Foundation
import UIKit
import Kingfisher


class MDMangaCellTagItem: UIView {
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    let contentLabel = UILabel(fontSize: 15, color: .white)
    
    init() {
        super.init(frame: .zero)
        
        self.layer.cornerRadius = 3
        self.theme_backgroundColor = UIColor.theme_tintColor
        
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
    }
}

class MDMangaTableCell: UITableViewCell {
    // MARK: - properties
    var coverImageView: UIImageView = {
        let view = UIImageView.init(imageNamed: "manga_cover_default")
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    var titleLabel = UILabel(fontSize: 18, fontWeight: .medium, color: .black2D2E2F, numberOfLines: 2, scalable: true)
    var statusTag = MDMangaCellTagItem()
    var updateTag = MDMangaCellTagItem()
    
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
        coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(60)
            make.height.equalTo(90)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(coverImageView.snp.right).offset(20)
            make.top.equalToSuperview().inset(15)
            make.right.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(statusTag)
        statusTag.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(updateTag)
        updateTag.snp.makeConstraints { make in
            make.top.equalTo(statusTag)
            make.right.equalToSuperview().inset(10)
        }
    }
    
    // MARK: - methods
    func setContentWithItem(_ item: MangaItem) {
        titleLabel.text = item.title
        if (item.status == "ongoing") {
            statusTag.contentLabel.text = "kMangaOngoing".localized()
        } else {
            statusTag.contentLabel.text = "kMangaCompleted".localized()
        }
        updateTag.contentLabel.text = "kMangaLastUpdate".localizedPlural(
            MDFormatter.formattedDateString(fromISODateString: item.updatedAt)
        )
        
        MDHTTPManager()
            .getMangaCoverUrlById(item.coverId, forManga: item.id) { url in
                DispatchQueue.main.async {
                    self.coverImageView.kf.setImage(with: url, placeholder: UIImage(named: "manga_cover_default"))
                }
            }
    }
}
