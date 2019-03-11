//
//  HomeViewController.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 1/16/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController {

    var feeds = [Feed]()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        YasumiService.shared.apiGetFeed { (feeds) in
            self.feeds = feeds
            self.tableView.reloadData()
        }
        notification()
        
        if Yasumi.session?.role == .admin {
            // Get notification data
            YasumiService.shared.apiGetNotification(options: [String: String]()) { (feeds) in
                if let tabItems = self.tabBarController?.tabBar.items {
                    // In this case we want to modify the badge number of the third tab:
                    let tabItem = tabItems[4]
                    tabItem.badgeValue = String(feeds.count)
                }
            }
        } else {
            // Get notification data
            YasumiService.shared.apiGetNotification(options: [String: String]()) { (feeds) in
                if let tabItems = self.tabBarController?.tabBar.items {
                    // In this case we want to modify the badge number of the third tab:
                    let tabItem = tabItems[3]
                    tabItem.badgeValue = String(feeds.count)
                }
            }
        }
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func notification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.notificationListener(notification:)),
            name: NSNotification.Name(rawValue: "postSuccess"),
            object: nil)
    }
    @objc func notificationListener(notification: NSNotification) {
        refresh()
    }
    
    @objc func refresh() {
        YasumiService.shared.apiGetFeed { (feeds) in
            self.feeds = feeds
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.selectionStyle = .none

        let s = feeds[indexPath.row].status
        if s == "APPROVED" || s == "approved" {
            cell.backgroundColor = UIColor(red: 78 / 255, green: 207 / 255, blue: 108 / 255, alpha: 0.15)
        } else if s == "DENY" || s == "deny" || s == "DENIED" || s == "denied" {
            cell.backgroundColor = UIColor(red: 1, green: 162 / 255, blue: 140 / 255, alpha: 0.15)
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        let avatarImageView = cell.contentView.viewWithTag(2000) as! UIImageView
        avatarImageView.sd_setImage(with: URL(string: feeds[indexPath.row].author!.avatar ?? ""), completed: nil)

        let nameLabel = cell.contentView.viewWithTag(2001) as! UILabel
        nameLabel.text = feeds[indexPath.row].author?.name
        
        let emotionLable = cell.contentView.viewWithTag(2002) as! UILabel
        emotionLable.text = "feeling " + feeds[indexPath.row].emotion!
        
        let timeLabel = cell.contentView.viewWithTag(2003) as! UILabel
        timeLabel.text = feeds[indexPath.row].createAt

        // Off / leave
        let typeLabel = cell.contentView.viewWithTag(2004) as! UILabel
        let durationLabel = cell.contentView.viewWithTag(2005) as! UILabel
        
        if feeds[indexPath.row].info == "leave" {
            typeLabel.text = "Would like to ask for \(feeds[indexPath.row].check ?? "-")"
            
            var start = feeds[indexPath.row].start ?? "-"
            if start.count > 3 {
                let endIndex = start.index(start.endIndex, offsetBy: -3)
                start = start.substring(to: endIndex)
            }
            
            var end = feeds[indexPath.row].end ?? "-"
            if end.count > 3 {
                let endIndex = end.index(end.endIndex, offsetBy: -3)
                end = end.substring(to: endIndex)
            }
            
            durationLabel.text = start + " -> " + end
        } else {
            typeLabel.text = "Would like to ask for off:"
            
            durationLabel.text = feeds[indexPath.row].date ?? "-"
        }
        
        let reasonLabel = cell.contentView.viewWithTag(2007) as! UILabel
        reasonLabel.text = feeds[indexPath.row].reason

        let statusLabel = cell.contentView.viewWithTag(2008) as! UILabel
        statusLabel.text = feeds[indexPath.row].status
        
        cell.separatorInset = UIEdgeInsets.zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let board = UIStoryboard(name: "Quy", bundle: nil)
        let detailVC = board.instantiateViewController(withIdentifier: "detailBoard") as! YasumiDetailViewController
        detailVC.article = feeds[indexPath.row]

        self.navigationController?.pushViewController(detailVC, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
}
