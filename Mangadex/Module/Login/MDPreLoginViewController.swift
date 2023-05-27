//
// Created by John Rion on 2021/7/3.
//

import Foundation
import UIKit
import SnapKit

class MDPreLoginAccountView: UICollectionViewCell {
    private var ivAvatar = UIImageView(named: "icon_avatar_round")
    private var lblName = UILabel(fontSize: 18, fontWeight: .light).apply { label in
        label.numberOfLines = 2
        label.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.makeConstraints { (make: ConstraintMaker) in
            make.edges.equalTo(0)
            make.width.equalTo(100)
        }
        
        contentView.addSubview(ivAvatar)
        ivAvatar.snp.makeConstraints { (make: ConstraintMaker) in
            make.width.height.equalTo(100)
            make.top.left.right.equalToSuperview()
        }
        ivAvatar.layer.cornerRadius = 50
        
        contentView.addSubview(lblName)
        lblName.snp.makeConstraints { (make: ConstraintMaker) in
            make.centerX.equalTo(ivAvatar)
            make.top.equalTo(ivAvatar.snp.bottom).offset(20)
            make.left.right.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func updateWithCredential(_ credential: Credential) {
        lblName.text = credential.username
    }
}

class MDPreLoginViewController: BaseViewController {
    private lazy var credentials: [Credential] = []
    private lazy var lblTitle = UILabel(fontSize: 22, fontWeight: .medium, scalable: true).apply {
        label in
        label.text = "kSavedAccounts".localized()
    }
    private lazy var btnDismiss = UIButton(type: .system).apply { button in
        button.setTitle("kSavedAccountsDismiss".localized(), for: .normal)
        button.theme_setTitleColor(UIColor.themePrimaryPicker, forState: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        button.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
    }
    
    private lazy var vAccounts: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.register(MDPreLoginAccountView.self, forCellWithReuseIdentifier: "account")
        return view
    }()
    
    override func willSetupUI() {
        credentials = MDKeychain.read()
    }
    
    override func setupUI() {
        view.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(MDLayout.safeInsetTop + 50)
        }
        
        view.addSubview(btnDismiss)
        btnDismiss.snp.makeConstraints { (make: ConstraintMaker) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(MDLayout.safeInsetBottom + 20)
        }
        
        view.addSubview(vAccounts)
        vAccounts.snp.makeConstraints { (make: ConstraintMaker) in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(200)
        }
    }
    
    @objc func didTapDismiss() {
        let vc = MDLoginViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MDPreLoginViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        credentials.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "account",
            for: indexPath
        )
            as! MDPreLoginAccountView
        cell.updateWithCredential(credentials[indexPath.row])
        return cell
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let totalCellWidth = 100 * credentials.count
        let inset = (MDLayout.screenWidth - CGFloat(totalCellWidth)) / 2
        if (inset > 0) {
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        } else {
            return .zero
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let vc = MDLoginViewController(credential: credentials[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}
