//
//  AdminNotificationTableViewCell.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 2/21/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class AdminNotificationTableViewCell: UITableViewCell {

    var feed: Feed?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(feed: Feed) {
        self.feed = feed
        
        avatarImageView.sd_setImage(with: URL(string: feed.author?.avatar ?? ""), completed: nil)
        authorLabel.text = feed.author?.name ?? "-"
    }
}
