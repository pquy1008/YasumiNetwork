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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationCell")
        tableView.register(UINib(nibName: "AdminNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "adminNotificationCell")
        
        // Get notification data
        YasumiService.shared.apiGetNotification(options: [String: String]()) { (feeds) in
            self.notificationFeeds = feeds
            self.tableView.reloadData()
        }
    }
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationFeeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        cell.separatorInset = UIEdgeInsets.zero

        if Yasumi.session!.role == .user {
            // Normal user
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
            cell.separatorInset = UIEdgeInsets.zero
            
            cell.msgLabel.text = "Your request was \(notificationFeeds[indexPath.row].status ?? "-")"
            
            return cell
        } else {
            // Admin or manager
            let cell = tableView.dequeueReusableCell(withIdentifier: "adminNotificationCell", for: indexPath) as! AdminNotificationTableViewCell
            cell.separatorInset = UIEdgeInsets.zero
            
            return cell
        }
    }
}
