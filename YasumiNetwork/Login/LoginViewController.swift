//
//  LoginViewController.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 1/16/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        let loginUrl = URL(string: "http://192.168.0.22/chatwork/api/login")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(loginUrl!, options: [:], completionHandler: nil)
        } else {
            // Do nothing
        }
    }
}
