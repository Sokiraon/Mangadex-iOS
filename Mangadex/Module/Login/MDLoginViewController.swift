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
import PromiseKit

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
    
    private lazy var btnLogin: MDButton = {
        let button = MDButton(variant: .contained)
        button.setTitle("kLoginUser".localized(), for: .normal)
        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var btnGuest: MDButton = {
        let button = MDButton(variant: .outlined)
        button.setTitle("kLoginGuest".localized(), for: .normal)
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
        
        view.addSubview(btnLogin)
        btnLogin.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        
        view.addSubview(btnGuest)
        btnGuest.snp.makeConstraints { make in
            make.top.equalTo(btnLogin.snp.bottom).offset(15)
            make.left.right.height.equalTo(btnLogin)
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
        
        firstly {
            MDUserManager.getInstance().login(username: username, password: password)
        }.done { res in
            DispatchQueue.main.async {
                let vc = MDHomeTabViewController()
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
        }.catch { error in
            self.shouldAutoLogin = false
            DispatchQueue.main.async {
                ProgressHUD.showError()
                self.view.isUserInteractionEnabled = true
            }
        }
    }

    @objc func didTapGuest() {
        let vc = MDHomeTabViewController()
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

