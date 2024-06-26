//
//  MangaViewerCollectionCell.swift
//  Mangadex
//
//  Created by John Rion on 2021/6/26.
//

import Foundation
import UIKit
import Kingfisher
import SnapKit

class MangaViewerCollectionCell: UICollectionViewCell {
    
    private lazy var vScroll = UIScrollView().apply { view in
        view.backgroundColor = .black
        view.delegate = self
        view.minimumZoomScale = 1
        view.maximumZoomScale = 3
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
    }
    
    private lazy var ivPage = UIImageView().apply { iv in
        iv.kf.indicatorType = .activity
        iv.contentMode = .scaleAspectFit
    }
    
    var imageURL: URL? = nil {
        didSet {
            ivPage.kf.setImage(with: imageURL, options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage,
            ])
        }
    }
    
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
        
        vScroll.addSubview(ivPage)
        ivPage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(MDLayout.screenWidth)
            make.height.equalTo(MDLayout.screenHeight)
        }
    }
    
    @objc func handleTapGesture(_ gesture: ShortTapGestureRecognizer) {
        if vScroll.zoomScale > 1 {
            vScroll.setZoomScale(1, animated: true)
        } else {
            let touchPoint = gesture.location(in: ivPage)
            let newScale: CGFloat = 2.0
            let width = contentView.frame.width / newScale
            let height = contentView.frame.height / newScale
            vScroll.zoom(
                    to: CGRect(x: touchPoint.x - width / 2, y: touchPoint.y - height / 2,
                               width: width, height: height),
                    animated: true
            )
        }
    }
    
    func resetScale() {
        vScroll.setZoomScale(1, animated: false)
    }
}

extension MangaViewerCollectionCell: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        ivPage
    }
}
