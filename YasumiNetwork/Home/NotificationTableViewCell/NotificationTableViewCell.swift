//
//  NotificationTableViewCell.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 2/21/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    var joBoss: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Find admin avatar
        joBoss = Yasumi.userLst.filter { (u) -> Bool in
            return u.role == .admin
        }.first
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(feed: Feed) {
//        avatarImageView.sd_setImage(with: URL(string: joBoss?.avatar ?? ""), completed: nil)
//        authorNameLabel.text = joBoss?.name ?? "-"
        authorNameLabel.text = "-"
        msgLabel.text = "Your request was \(feed.status ?? "-")"
        
        if let isoDate = feed.createAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = dateFormatter.date(from:isoDate) {
                timerLabel.text = date.getElapsedInterval()
            }
        }
        
        if let isoDate = feed.approveAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = dateFormatter.date(from:isoDate) {
                timerLabel.text = date.getElapsedInterval()
            }
        }
    }
}
