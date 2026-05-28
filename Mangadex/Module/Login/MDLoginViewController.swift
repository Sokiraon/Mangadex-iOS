//
//  ViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/12.
//

import UIKit
import SnapKit
import ProgressHUD
import Loaf

fileprivate let queue = DispatchQueue(label: "serial")

class MDLoginViewController: BaseViewController, UITextFieldDelegate {
    
    private let formView = CardView()

    private let usernameLabel = UILabel(
        fontSize: 14,
        fontWeight: .medium,
        color: .primaryText
    ).apply { label in
        label.text = "login.usernameOrEmail".localized()
    }
    
    lazy var fieldUsername = MDTextField().apply { field in
        field.placeholder = "kLoginUsername".localized()
        field.textContentType = .username
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .white
        field.leftView = Self.makeTextFieldIconView(systemName: "person")
        field.leftViewMode = .always
        
        field.layer.borderWidth = 2
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.grayDFDFDF.cgColor
    }

    private let passwordLabel = UILabel(
        fontSize: 14,
        fontWeight: .medium,
        color: .primaryText
    ).apply { label in
        label.text = "kLoginPassword".localized()
    }
    
    lazy var fieldPassword = MDTextField().apply { field in
        field.placeholder = "kLoginPassword".localized()
        field.textContentType = .password
        field.returnKeyType = .go
        field.enablesReturnKeyAutomatically = true
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        field.isSecureTextEntry = true
        field.backgroundColor = .white
        field.leftView = Self.makeTextFieldIconView(systemName: "lock")
        field.leftViewMode = .always
        
        field.layer.borderWidth = 2
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.grayDFDFDF.cgColor
    }
    
    private lazy var btnLogin = UIButton(
        configuration: loginButtonConfiguration,
        primaryAction: UIAction { [weak self] _ in
            self?.didTapLogin()
        }
    )
    
    private lazy var btnGuest = UIButton(
        configuration: guestButtonConfiguration,
        primaryAction: UIAction { [weak self] _ in
            self?.didTapGuest()
        }
    )

    private var loginButtonConfiguration: UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = "kLoginUser".localized()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .themePrimary
        config.cornerStyle = .capsule
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 18)
            return outgoing
        }
        return config
    }

    private var guestButtonConfiguration: UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.title = "kLoginGuest".localized()
        config.baseForegroundColor = .themeDark
        config.cornerStyle = .capsule
        config.background.backgroundColor = .white
        config.background.strokeColor = .themePrimary
        config.background.strokeWidth = 2
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 18)
            return outgoing
        }
        return config
    }
    
    private var usernameInput: String {
        fieldUsername.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private var passwordInput: String {
        fieldPassword.text ?? ""
    }

    private static func makeTextFieldIconView(systemName: String) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 24))
        let image = UIImage(
            systemName: systemName,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 17,
                weight: .medium
            )
        )
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .darkGray808080
        imageView.frame = CGRect(x: 16, y: 2, width: 20, height: 20)
        container.addSubview(imageView)
        return container
    }
    
    override func setupUI() {
        view.addSubview(formView)
        formView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        formView.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        formView.addSubview(fieldUsername)
        fieldUsername.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(usernameLabel)
        }
        fieldUsername.delegate = self
        fieldUsername.tag = 0
        fieldUsername.addTarget(
            self,
            action: #selector(updateLoginButtonState),
            for: .editingChanged
        )
        fieldUsername.addTarget(
            self,
            action: #selector(didBeginEditingTextField(_:)),
            for: .editingDidBegin
        )
        fieldUsername.addTarget(
            self,
            action: #selector(didEndEditingTextField(_:)),
            for: .editingDidEnd
        )
        
        formView.addSubview(passwordLabel)
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(fieldUsername.snp.bottom).offset(16)
            make.leading.trailing.equalTo(fieldUsername)
        }

        formView.addSubview(fieldPassword)
        fieldPassword.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(passwordLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(fieldUsername)
        }
        fieldPassword.delegate = self
        fieldPassword.tag = 1
        fieldPassword.addTarget(
            self,
            action: #selector(updateLoginButtonState),
            for: .editingChanged
        )
        fieldPassword.addTarget(
            self,
            action: #selector(didBeginEditingTextField(_:)),
            for: .editingDidBegin
        )
        fieldPassword.addTarget(
            self,
            action: #selector(didEndEditingTextField(_:)),
            for: .editingDidEnd
        )
        
        formView.addSubview(btnLogin)
        btnLogin.snp.makeConstraints { make in
            make.top.equalTo(fieldPassword.snp.bottom).offset(32)
            make.leading.trailing.equalTo(fieldUsername)
            make.height.equalTo(48)
        }
        
        formView.addSubview(btnGuest)
        btnGuest.snp.makeConstraints { make in
            make.top.equalTo(btnLogin.snp.bottom).offset(16)
            make.leading.trailing.height.equalTo(btnLogin)
            make.bottom.equalToSuperview().inset(24)
        }

        updateLoginButtonState()
    }
    
    @objc func didTapLogin() {
        guard !usernameInput.isEmpty, !passwordInput.isEmpty else {
            Loaf(
                "kLoginMissingFields".localized(),
                state: .info,
                sender: self
            ).show(.short)
            return
        }

        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            ProgressHUD.animate()
        }
        
        let username = usernameInput
        let password = passwordInput
        
        Task {
            do {
                try await UserManager.shared.login(username: username, password: password)
                await MainActor.run {
                    ProgressHUD.dismiss()
                    self.view.isUserInteractionEnabled = true
                    MDRouter.goToHome()
                }
            } catch {
                await MainActor.run {
                    ProgressHUD.failed()
                    self.view.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    @objc func didTapGuest() {
        Task { @MainActor in
            await UserManager.shared.loginAsGuest()
            MDRouter.goToHome()
        }
    }

    @objc private func updateLoginButtonState() {
        btnLogin.isEnabled = !usernameInput.isEmpty && !passwordInput.isEmpty
    }

    @objc private func didBeginEditingTextField(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.themePrimary.cgColor
        updateTextFieldIconColor(textField, color: .themePrimary)
    }

    @objc private func didEndEditingTextField(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.grayDFDFDF.cgColor
        updateTextFieldIconColor(textField, color: .darkGray808080)
    }

    private func updateTextFieldIconColor(
        _ textField: UITextField,
        color: UIColor
    ) {
        let iconView = textField.leftView?.subviews.first { view in
            view is UIImageView
        } as? UIImageView
        iconView?.tintColor = color
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if btnLogin.isEnabled {
                didTapLogin()
            }
        }
        return false
    }
}
