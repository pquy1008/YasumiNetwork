//
//  ParrentViewController.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 1/16/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class ParrentViewController: UITabBarController {
    
    var selectIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        // Load user profile at the begin
        
    }
    
}

extension ParrentViewController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
            
            return false;
            
            if viewController.title == "Add"
            {
                return false
            } else {
                return true
            }
        }
        
        
//        if item.tag == 13 {
//            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//            let offAction = UIAlertAction(title: "I'll off of work...", style: .default) { (action) in
//                //
//            }
//
//            let lateAction = UIAlertAction(title: "I'll comming late/leaving soon...", style: .default) { (action) in
//                //
//            }
//
//            alertVC.addAction(offAction)
//            alertVC.addAction(lateAction)
//
//            self.present(alertVC, animated: true, completion: nil)
//        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        switch tabBarController.selectedIndex {
        case 1:
            self.selectedIndex = selectIndex
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "add") as! AddViewController
            self.present(vc, animated: true, completion: nil)
            
        case 2:
            self.selectedIndex = selectIndex
            let quyStoryboard = UIStoryboard(name: "Quy", bundle: nil)
            let vc = quyStoryboard.instantiateViewController(withIdentifier: "profileNavBoard")
            self.present(vc, animated: true, completion: nil)
            
        default:
            break
            // Do nothing
        }
        
        selectIndex = tabBarController.selectedIndex
    }
}
