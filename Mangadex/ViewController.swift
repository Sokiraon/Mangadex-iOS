//
//  ViewController.swift
//  Mangadex
//
//  Created by edz on 2021/5/12.
//

import UIKit
import SnapKit
import MaterialComponents

class ViewController: UIViewController, UITextFieldDelegate {
    let usernameField: MDCOutlinedTextField = {
        let field = MDCOutlinedTextField()
        field.label.text = "Username"
        field.textContentType = .username
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .white
        return field
    }()
    
    let passwordField: MDCOutlinedTextField = {
        let field = MDCOutlinedTextField()
        field.label.text = "Password"
        field.textContentType = .password
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        field.isSecureTextEntry = true
        field.backgroundColor = .white
        return field
    }()
    
    let loginButton: MDCButton = {
        let button = MDCButton()
        button.setTitle("login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapLogin(sender:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(usernameField)
        usernameField.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(view).offset(-100)
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
    }
    
    @objc func didTapLogin(sender: Any) {
        let result = MangadexAuth.getInstance().loginWithPassword(username: usernameField.text!,
                                                                  password: passwordField.text!)
        if (result) {
            let dashboardStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            if let controller = dashboardStoryboard.instantiateViewController(withIdentifier: "Dashboard") as? DashboardViewController {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
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

