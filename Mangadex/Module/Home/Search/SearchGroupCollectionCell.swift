//
//  SearchGroupCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/06.
//

import Foundation
import UIKit

class SearchGroupCollectionCell: UICollectionViewCell, Highlightable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let lblName = UILabel(fontSize: 18, fontWeight: .medium)
    private let lblLeader = UILabel(fontSize: 16)
    
    private func setupUI() {
        backgroundColor = .lightestGrayF5F5F5
        layer.cornerRadius = 8
        
        contentView.addSubview(lblName)
        lblName.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(12)
        }
        
        contentView.addSubview(lblLeader)
        lblLeader.snp.makeConstraints { make in
            make.top.equalTo(lblName.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    func setContent(groupModel: ScanGroupModel) {
        lblName.text = groupModel.attributes.name
        if let leaderName = groupModel.leader?.attributes?.username {
            lblLeader.text = "search.group.leader".localizedFormat(leaderName)
        } else {
            lblLeader.text = "search.group.noLeader".localized()
        }
    }
    
    func didHighlighted() {
        backgroundColor = .grayDFDFDF
    }
    
    func didUnHighlighted() {
        backgroundColor = .lightestGrayF5F5F5
    }
}
