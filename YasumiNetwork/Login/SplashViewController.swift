//
//  SplashViewController.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 2/19/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Update profile
        YasumiService.shared.apiGetProfile { (user) in
            Yasumi.session = user
            
            let board = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = board.instantiateViewController(withIdentifier: "homeBoard")
            self.present(homeVC, animated: true, completion: nil)
        }
    }
}
