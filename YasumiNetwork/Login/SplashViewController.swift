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
            let homeVC = board.instantiateViewController(withIdentifier: "homeBoard") as! ParrentViewController
            
            if user.role == .admin {
                // Remove create post
                homeVC.viewControllers?.remove(at: 1)

                // Waiting list
                let quyBoard = UIStoryboard(name: "Quy", bundle: nil)
                let waitingListVC = quyBoard.instantiateViewController(withIdentifier: "waitingListBoard")
                waitingListVC.title = "Waiting list"
                let navVC = UINavigationController()
                navVC.addChild(waitingListVC)
                homeVC.viewControllers?.insert(navVC, at: 1)
                waitingListVC.tabBarItem.title = nil
                waitingListVC.tabBarItem.image = UIImage(named: "checklist")
                waitingListVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
                
                // Search page
                let userHistoryVC = quyBoard.instantiateViewController(withIdentifier: "userHistoryBoard")
                userHistoryVC.title = "User History"
                let navVC2 = UINavigationController()
                navVC2.addChild(userHistoryVC)
                homeVC.viewControllers?.insert(navVC2, at: 2)
                userHistoryVC.tabBarItem.title = nil
                userHistoryVC.tabBarItem.image = UIImage(named: "history")
                userHistoryVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
                
                // Get user list
                YasumiService.shared.apiGetAllMember(success: { (users) in
                    Yasumi.userLst = users
                })
            }
            
            self.present(homeVC, animated: true, completion: nil)
        }
    }
}
