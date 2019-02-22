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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        YasumiService.shared.apiGetFeed { (feeds) in
            self.feeds = feeds
            self.tableView.reloadData()
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

        let avatarImageView = cell.contentView.viewWithTag(2000) as! UIImageView
        avatarImageView.sd_setImage(with: URL(string: feeds[indexPath.row].author!.avatar ?? ""), completed: nil)

        let nameLabel = cell.contentView.viewWithTag(2001) as! UILabel
        nameLabel.text = feeds[indexPath.row].author?.name
        
        let emotionLable = cell.contentView.viewWithTag(2002) as! UILabel
        emotionLable.text = feeds[indexPath.row].emotion
        
        let timeLabel = cell.contentView.viewWithTag(2003) as! UILabel
        timeLabel.text = feeds[indexPath.row].createAt

        
        let reasonLabel = cell.contentView.viewWithTag(2007) as! UILabel
        reasonLabel.text = feeds[indexPath.row].reason
        
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
