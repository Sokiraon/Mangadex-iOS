//
//  SearchAuthorCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/06.
//

import Foundation
import UIKit

class SearchAuthorCollectionCell: UICollectionViewCell, Highlightable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let lblName = UILabel(fontSize: 17, fontWeight: .medium)
    private let lblTitleCount = UILabel(fontSize: 15)
    
    private func setupUI() {
        backgroundColor = .lightestGrayF5F5F5
        layer.cornerRadius = 8
        
        contentView.addSubview(lblName)
        lblName.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.equalToSuperview().inset(12)
        }
        
        contentView.addSubview(lblTitleCount)
        lblTitleCount.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(lblName.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
        }
    }
    
    func setContent(authorModel: AuthorModel) {
        lblName.text = authorModel.attributes.name
        if authorModel.relationships.count == 1 {
            lblTitleCount.text = "search.author.titleCount.single".localized()
        } else if authorModel.relationships.count > 1 {
            lblTitleCount.text = "search.author.titleCount.multiple"
                .localizedFormat(authorModel.relationships.count)
        }
    }
    
    func didHighlighted() {
        backgroundColor = .grayDFDFDF
    }
    
    func didUnHighlighted() {
        backgroundColor = .lightestGrayF5F5F5
    }
}
