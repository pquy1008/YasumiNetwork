//
//  YasumiDetailViewController.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 2/22/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class YasumiDetailViewController: UIViewController {

    var article: Feed?
    var comments = [Comment]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get detail
        var opt = [String: String]()
        var isOff = false
        
        if article?.info == "off" {
            opt = ["off_id": article?.id ?? "-"]
            isOff = true
        } else {
            opt = ["leave_id": article?.id ?? "-"]
            isOff = false
        }
        
        YasumiService.shared.apiGetComment(isOff: isOff, options: opt) { (comments) in
            self.comments = comments
            self.tableView.reloadData()
        }
        
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        keyboardHeightConstraint.constant = 0
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeightConstraint.constant = -keyboardSize.height
            view.layoutIfNeeded()
            
            print("SHOW")
            print(keyboardSize.height)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeightConstraint.constant = 0
        view.layoutIfNeeded()
        
        print("HIDE")
    }
    
    @IBAction func postCommentTapped(_ sender: UIButton) {
        let msg = commentTextField.text
        
        if msg == "" {return}

        var options = [
            "leave_id": article?.id ?? "",
            "comment": msg!,
            "off_id": "0"
        ]
        
        if article?.info == "off" {
            options["off_id"] = article?.id ?? ""
            options["leave_id"] = "0"
        }
        
        YasumiService.shared.apiPostComment(options: options, success: {
            self.view.endEditing(true)
            self.commentTextField.text = ""
            
            // Apend comment
            let c = Comment()
            c.id = ""
            c.avatar = Yasumi.session?.avatar
            c.name = Yasumi.session?.name
            let date = NSDate()
            c.createAt = date.format("yyyy-MM-dd HH:mm")
            c.msg = options["comment"]
            
            self.comments.append(c)
            self.tableView.reloadData()
        }) {
            self.view.endEditing(true)
        }
    }
}

extension YasumiDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Article cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            cell.separatorInset = UIEdgeInsets.zero
            
            let avatarImgView = cell.contentView.viewWithTag(2000) as! UIImageView
            avatarImgView.sd_setImage(with: URL(string: article?.author?.avatar ?? ""), completed: nil)
            
            let nameLabel = cell.contentView.viewWithTag(2001) as! UILabel
            nameLabel.text = article?.author?.name ?? "-"
            
            let emotionLabel = cell.contentView.viewWithTag(2002) as! UILabel
            emotionLabel.text = "- " + (article?.emotion ?? "-")
            
            let timerLabel = cell.contentView.viewWithTag(2003) as! UILabel
            timerLabel.text = article?.createAt ?? "-"
            
            // Waiting
            let waitingLabel = cell.contentView.viewWithTag(2008) as! UILabel
            waitingLabel.text = article?.status ?? "-"
            
            let offDate = cell.contentView.viewWithTag(2005) as! UILabel
            offDate.text = article?.date ?? "-"
            
            let resonLable = cell.contentView.viewWithTag(2007) as! UILabel
            resonLable.text = article?.reason ?? "-"
            
            return cell
        }
        else {
            // Comment cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
            cell.separatorInset = UIEdgeInsets.zero
            
            let avatarImageView = cell.contentView.viewWithTag(1000) as! UIImageView
            avatarImageView.sd_setImage(with: URL(string: comments[indexPath.row - 1].avatar ?? ""), completed: nil)
            
            let authorLabel = cell.viewWithTag(1001) as! UILabel
            authorLabel.text = comments[indexPath.row - 1].name
            
            let timerLabel = cell.viewWithTag(1002) as! UILabel
            timerLabel.text = comments[indexPath.row - 1].createAt
            timerLabel.text = "2018-2-12 00:23"
            
            let msgLabel = cell.viewWithTag(1003) as! UILabel
            msgLabel.text = comments[indexPath.row - 1].msg
            
            return cell
        }
    }
    
    
}
