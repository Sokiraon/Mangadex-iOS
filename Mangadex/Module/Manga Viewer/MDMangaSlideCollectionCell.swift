//
//  MDMangaSlideCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/26.
//

import Foundation
import UIKit
import Kingfisher
import SnapKit

class MDMangaSlideCollectionCell: UICollectionViewCell {
    private lazy var vScroll: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.minimumZoomScale = 1
        view.maximumZoomScale = 3
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    private lazy var vScrollContent = UIView()
    private lazy var ivPage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        contentView.addSubview(vScroll)
        vScroll.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

//        vScroll.addSubview(vScrollContent)
//        vScrollContent.snp.makeConstraints { (make: ConstraintMaker) in
//            make.edges.equalToSuperview()
//        }

        vScroll.addSubview(ivPage)
        ivPage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
            make.height.equalTo(MDLayout.screenHeight)
        }
    }

    func setImageUrl(_ url: String) {
        ivPage.kf.setImage(with: URL(string: url))
    }
}

extension MDMangaSlideCollectionCell: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        ivPage
    }
}
