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

fileprivate let queue = DispatchQueue(label: "serial")

class MDLoginViewController: MDViewController, UITextFieldDelegate {
    let usernameField: MDCOutlinedTextField = {
        let field = MDCOutlinedTextField()
        field.label.text = "kLoginUsername".localized()
        field.text = "Sokiraon"
        field.textContentType = .username
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .white
        return field
    }()
    
    let passwordField: MDCOutlinedTextField = {
        let field = MDCOutlinedTextField()
        field.label.text = "kLoginPassword".localized()
        field.text = "EbfKkZX7LePz5R5"
        field.textContentType = .password
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        field.isSecureTextEntry = true
        field.backgroundColor = .white
        return field
    }()
    
    let loginButton: MDCButton = {
        let button = MDCButton()
        button.setTitle("kLoginUser".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapLogin(sender:)), for: .touchUpInside)
        return button
    }()
    
    let guestButton: MDCButton = {
        let button = MDCButton()
        button.setTitle("kLoginGuest".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapGuest(sender:)), for: .touchUpInside)
        return button
    }()

    override func setupUI() {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isToolbarHidden = true
        
        view.backgroundColor = .white
        
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
    
    @objc func didTapLogin(sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        MDUser.getInstance()
            .loginWithUsername(username, andPassword: password) {
                DispatchQueue.main.async {
                    let vc = MDHomeViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } onError: {
                DispatchQueue.main.async {
                    ProgressHUD.showError()
                }
            }
    }
    
    @objc func didTapGuest(sender: Any) {
        let vc = MDHomeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
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

