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
import PromiseKit

fileprivate let queue = DispatchQueue(label: "serial")

class MDLoginViewController: BaseViewController, UITextFieldDelegate {
    
    lazy var fieldUsername = MDTextField().apply { field in
        field.placeholder = "kLoginUsername".localized()
        field.textContentType = .username
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .white
        
        field.layer.borderWidth = 2
        field.layer.cornerRadius = 4
        field.layer.theme_borderColor = UIColor.themePrimaryCgPicker
    }
    
    lazy var fieldPassword = MDTextField().apply { field in
        field.placeholder = "kLoginPassword".localized()
        field.textContentType = .password
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        field.isSecureTextEntry = true
        field.backgroundColor = .white
        
        field.layer.borderWidth = 2
        field.layer.cornerRadius = 4
        field.layer.theme_borderColor = UIColor.themePrimaryCgPicker
    }
    
    private lazy var btnLogin = MDButton(variant: .contained).apply { button in
        button.setTitle("kLoginUser".localized(), for: .normal)
        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    }
    
    private lazy var btnGuest = MDButton(variant: .outlined).apply { button in
        button.setTitle("kLoginGuest".localized(), for: .normal)
        button.addTarget(self, action: #selector(didTapGuest), for: .touchUpInside)
    }
    
    private var shouldAutoLogin = false
    
    convenience init(credential: Credential) {
        self.init()
        fieldUsername.text = credential.username
        fieldPassword.text = credential.password
        shouldAutoLogin = true
    }
    
    override func setupUI() {
        view.addSubview(fieldUsername)
        fieldUsername.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(view).offset(-100)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
        }
        fieldUsername.delegate = self
        fieldUsername.tag = 0
        
        view.addSubview(fieldPassword)
        fieldPassword.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(fieldUsername.snp.bottom).offset(16)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
        }
        fieldPassword.delegate = self
        fieldPassword.tag = 1
        
        view.addSubview(btnLogin)
        btnLogin.snp.makeConstraints { make in
            make.top.equalTo(fieldPassword.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        
        view.addSubview(btnGuest)
        btnGuest.snp.makeConstraints { make in
            make.top.equalTo(btnLogin.snp.bottom).offset(16)
            make.left.right.height.equalTo(btnLogin)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldAutoLogin {
            didTapLogin()
        }
    }
    
    @objc func didTapLogin() {
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            ProgressHUD.show()
        }
        
        let username = fieldUsername.text!
        let password = fieldPassword.text!
        
        firstly {
            UserManager.shared.login(username: username, password: password)
        }
            .done { res in
                UserManager.logOutAsGuest()
                DispatchQueue.main.async {
                    let vc = MDHomeTabViewController()
                    ProgressHUD.dismiss()
                    self.view.isUserInteractionEnabled = true
                    if (!self.shouldAutoLogin) {
                        let saveAlert = UIAlertController.initWithTitle(
                            "kKeychainSaveTitle".localized(),
                            message: "kKeychainSaveMessage".localized(),
                            style: .actionSheet,
                            actions:
                            AlertViewAction(title: "kOk".localized(), style: .default) { action in
                                MDKeychain.add(username: username, password: password, onSuccess: {
                                    Loaf(
                                        "kSaveSuccess".localized(),
                                        state: .success,
                                        sender: self
                                    ).show(.short) { reason in
                                        self.navigationController?
                                            .pushViewController(vc, animated: true)
                                    }
                                }, onError: { error in
                                    Loaf(
                                        "kKeychainSaveError".localized(),
                                        state: .info,
                                        sender: self
                                    ).show(.short) { reason in
                                        self.navigationController?
                                            .pushViewController(vc, animated: true)
                                    }
                                })
                            },
                            AlertViewAction(title: "kNo".localized(), style: .cancel) { action in
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        )
                        self.present(saveAlert, animated: true)
                    } else {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            .catch { error in
                self.shouldAutoLogin = false
                DispatchQueue.main.async {
                    ProgressHUD.showError()
                    self.view.isUserInteractionEnabled = true
                }
            }
    }
    
    @objc func didTapGuest() {
        UserManager.shared.loginAsGuest()
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
}

