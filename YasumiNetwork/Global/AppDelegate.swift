//
//  AppDelegate.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 1/16/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if Yasumi.session == nil {
            Yasumi.session = User()
        }
        
        let email = url.queryParameters!["email"]
        Yasumi.session?.email = email!
        
        // Open splash app
//        let splashVC = UIStoryboard(name: "Quy", bundle: nil).instantiateViewController(withIdentifier: "splashBoard")
//        let board = UIStoryboard(name: "Main", bundle: nil)
//        let homeVC = board.instantiateViewController(withIdentifier: "homeBoard") as! ParrentViewController
//        self.window?.rootViewController?.present(splashVC, animated: true, completion: nil)
//        self.window?.rootViewController = homeVC
        
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
                userHistoryVC.title = "Search User"
                let navVC2 = UINavigationController()
                navVC2.addChild(userHistoryVC)
                homeVC.viewControllers?.insert(navVC2, at: 2)
                userHistoryVC.tabBarItem.title = nil
                userHistoryVC.tabBarItem.image = UIImage(named: "history")
                userHistoryVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            }
            
            // Get user list
            YasumiService.shared.apiGetAllMember(success: { (users) in
                Yasumi.userLst = users
            })
            
            self.window?.rootViewController = homeVC
        }
        
        
        
        // Save information
        let options = [
            "email":            url.queryParameters!["email"]!,
            "name":             url.queryParameters!["name"]!,
            "avatar":           url.queryParameters!["avatar"]!,
            "access_token":     url.queryParameters!["access_token"]!,
            "refresh_token":    url.queryParameters!["refresh_token"]!,
            "chatwork_id":      url.queryParameters!["chatwork_id"]!,
        ]
        YasumiService.shared.apiSaveInformation(options: options, success: {
            //
        }) {
            //
        }
        
        return true
    }
}


extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
