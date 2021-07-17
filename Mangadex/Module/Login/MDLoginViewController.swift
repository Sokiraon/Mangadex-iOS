//
//  ViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/12.
//

import UIKit
import SnapKit
import MaterialComponents
import ProgressHUD
import Loaf

fileprivate let queue = DispatchQueue(label: "serial")

class MDLoginViewController: MDViewController, UITextFieldDelegate {
    lazy var usernameField: MDCOutlinedTextField = {
        let field = MDCOutlinedTextField()
        field.label.text = "kLoginUsername".localized()
        field.textContentType = .username
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .white
        return field
    }()

    lazy var passwordField: MDCOutlinedTextField = {
        let field = MDCOutlinedTextField()
        field.label.text = "kLoginPassword".localized()
        field.textContentType = .password
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        field.isSecureTextEntry = true
        field.backgroundColor = .white
        return field
    }()

    lazy var loginButton: MDCButton = {
        let button = MDCButton()
        button.setTitle("kLoginUser".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        return button
    }()

    lazy var guestButton: MDCButton = {
        let button = MDCButton()
        button.setTitle("kLoginGuest".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapGuest), for: .touchUpInside)
        return button
    }()

    private var shouldAutoLogin = false
    static func initWithCredential(_ credential: Credential) -> MDLoginViewController {
        let vc = MDLoginViewController()
        vc.usernameField.text = credential.username
        vc.passwordField.text = credential.password
        vc.shouldAutoLogin = true
        return vc
    }

    override func setupUI() {
        view.addSubview(usernameField)
        usernameField.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(view).offset(-100)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
        }
        usernameField.delegate = self
        usernameField.tag = 0

        view.addSubview(passwordField)
        passwordField.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(usernameField.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
        }
        passwordField.delegate = self
        passwordField.tag = 1

        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(passwordField.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(50)
        }

        view.addSubview(guestButton)
        guestButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(10)
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(50)
        }
    }

    override func doOnAppear() {
        if (shouldAutoLogin) {
            didTapLogin()
        }
    }

    @objc func didTapLogin() {
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async { ProgressHUD.show() }

        let username = usernameField.text!
        let password = passwordField.text!

        MDUser.getInstance()
            .loginWithUsername(username, andPassword: password) {
                DispatchQueue.main.async {
                    let vc = MDHomeViewController()
                    ProgressHUD.dismiss()
                    self.view.isUserInteractionEnabled = true
                    if (!self.shouldAutoLogin) {
                        let saveAlert = UIAlertController.initWithTitle("kKeychainSaveTitle".localized(),
                                message: "kKeychainSaveMessage".localized(), style: .actionSheet,
                                actions:
                                AlertViewAction(title: "kOk".localized(), style: .default) { action in
                                    MDKeychain.add(username: username, password: password, onSuccess: {
                                        Loaf("kSaveSuccess".localized(), state: .success, sender: self).show(.short) { reason in
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                    }, onError: { error in
                                        Loaf("kKeychainSaveError".localized(), state: .info, sender: self).show(.short) { reason in
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                    })
                                },
                                AlertViewAction(title: "kNo".localized(), style: .cancel) { action in
                                    self.navigationController?.pushViewController(vc, animated: true)
                                })
                        self.present(saveAlert, animated: true)
                    } else {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } onError: {
                self.shouldAutoLogin = false
                DispatchQueue.main.async {
                    ProgressHUD.showError()
                    self.view.isUserInteractionEnabled = true
                }
            }
    }

    @objc func didTapGuest() {
        let vc = MDHomeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

