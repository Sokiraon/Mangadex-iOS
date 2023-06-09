//
//  BrowseMangaHeaderSupplementaryView.swift
//  Mangadex
//
//  Created by John Rion on 2023/06/08.
//

import Foundation
import UIKit
import SnapKit

class BrowseMangaHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel(fontSize: 27, fontWeight: .semibold)
    private var refreshButton: UIButton!
    
    var refreshHandler: ((_ view: BrowseMangaHeaderView) -> Void)?
    
    private var isRefreshing = false
    
    func setRefreshing(_ state: Bool) {
        self.isRefreshing = state
        self.refreshButton.setNeedsUpdateConfiguration()
    }
    
    convenience init(refreshHandler: @escaping (_ view: BrowseMangaHeaderView) -> Void) {
        self.init(frame: .zero)
        self.refreshHandler = refreshHandler
        setupUI()
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.text = "kHomeTabBrowse".localized()
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(12)
        }
        
        var config = UIButton.Configuration.plain()
        config.title = "browse.header.refresh".localized()
        config.image = .init(systemName: "arrow.clockwise")
        config.imagePadding = 4
        config.preferredSymbolConfigurationForImage = .init(scale: .medium)
        config.contentInsets = .init(top: 2, leading: 12, bottom: 2, trailing: 12)
        refreshButton = UIButton(configuration: config,
                                 primaryAction: UIAction { _ in self.refreshHandler?(self) })
        refreshButton.configurationUpdateHandler = { button in
            button.configuration?.showsActivityIndicator = self.isRefreshing
            button.isEnabled = !self.isRefreshing
        }
        addSubview(refreshButton)
        refreshButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
        }
    }
}
