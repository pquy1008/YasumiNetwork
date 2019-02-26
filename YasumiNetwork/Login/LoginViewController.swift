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
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Auto login
        loginButtonTapped(UIButton())
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        if Yasumi.session == nil {
            Yasumi.session = User()
        }
        
//        let email = "quypv@tmh-techlab.vn"            // role: User
//        let email = "huancaopro93@gmail.com"
//        let email = "thaovtp@tmh-techlab.vn"          // role: Manager
        let email = "jo@tmh-techlab.vn"                 // role: Admin
        Yasumi.session?.email = email
        
//         Open splash app
        let splashVC = UIStoryboard(name: "Quy", bundle: nil).instantiateViewController(withIdentifier: "splashBoard")
        present(splashVC, animated: true, completion: nil)
        
//        let loginUrl = URL(string: "http://192.168.0.22/chatwork/api/login")
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(loginUrl!, options: [:], completionHandler: nil)
//        } else {
//            // Do nothing
//        }
    }
}
