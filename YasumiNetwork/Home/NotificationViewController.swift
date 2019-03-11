//
//  NotificationViewController.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 1/16/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    var notificationFeeds = [Feed]()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let tabItems = tabBarController?.tabBar.items {
//            // In this case we want to modify the badge number of the third tab:
//            let tabItem = tabItems[4]
//            tabItem.badgeValue = "1"
//        }

        // Register cell
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationCell")
        tableView.register(UINib(nibName: "AdminNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "adminNotificationCell")
        
        // Get notification data
        YasumiService.shared.apiGetNotification(options: [String: String]()) { (feeds) in
            print(feeds.count)
            self.notificationFeeds = feeds
            self.tableView.reloadData()
        }
        
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(sender:AnyObject?) {
        YasumiService.shared.apiGetNotification(options: [String: String]()) { (feeds) in
            self.notificationFeeds = feeds
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quyBoard = UIStoryboard(name: "Quy", bundle: nil)
        let detailVC = quyBoard.instantiateViewController(withIdentifier: "detailBoard") as! YasumiDetailViewController
        detailVC.article = notificationFeeds[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationFeeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        cell.separatorInset = UIEdgeInsets.zero
        cell.selectionStyle = .none

        if Yasumi.session!.role == .user || Yasumi.session!.role == .manager {
            // Normal user
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
            cell.separatorInset = UIEdgeInsets.zero
            cell.config(feed: notificationFeeds[indexPath.row])
            
            return cell
        } else {
            // Admin
            let cell = tableView.dequeueReusableCell(withIdentifier: "adminNotificationCell", for: indexPath) as! AdminNotificationTableViewCell
            cell.separatorInset = UIEdgeInsets.zero            
            cell.config(feed: notificationFeeds[indexPath.row])
            
            return cell
        }
    }
}
