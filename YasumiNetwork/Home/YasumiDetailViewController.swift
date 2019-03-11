//
//  YasumiDetailViewController.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 2/22/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

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
    
    //Action
    @objc func optionTapped() {
        if Yasumi.session!.role == .admin {
            // show approve / deny
            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let approveAction = UIAlertAction(title: "Approve", style: .default) { (a) in
                let options = [
                    "id":       self.article!.id,
                    "info":     self.article!.info!,
                    "status":   "1"
                ]
                
                YasumiService.shared.apiJoBossAction(options: options, success: {
                    print("APROVED")
                    
                    // Update data in detail page
                    self.article?.status = "APPROVED"
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    
                    // Forece home reload data
                    if let homeVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? HomeViewController { homeVC.refresh() }
                    if let waitingVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? WaitingListViewController { waitingVC.refresh() }
                    if let historyVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? HistoryViewController { historyVC.refresh() }
                    if let notifiVC  = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? NotificationViewController { notifiVC.refresh(sender: nil)}
                    
                    self.updateTabBarBadgeValue()
                })
            }
            
            let denyAction = UIAlertAction(title: "Deny", style: .default) { (a) in
                let options = [
                    "id":       self.article!.id,
                    "info":     self.article!.info!,
                    "status":   "3"
                ]
                
                YasumiService.shared.apiJoBossAction(options: options, success: {
                    print("DENIED")

                    // Update data in detail page
                    self.article?.status = "DENIED"
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    
                    // Forece home reload data
                    if let homeVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? HomeViewController { homeVC.refresh() }
                    if let waitingVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? WaitingListViewController { waitingVC.refresh() }
                    if let historyVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? HistoryViewController { historyVC.refresh() }
                    if let notifiVC  = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? NotificationViewController { notifiVC.refresh(sender: nil)}
                    
                    self.updateTabBarBadgeValue()
                })
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertVC.addAction(approveAction)
            alertVC.addAction(denyAction)
            alertVC.addAction(cancelAction)
            
            self.present(alertVC, animated: true, completion: nil)
        } else {
            // show edit / delete
            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let editAction = UIAlertAction(title: "Edit", style: .default) { (a) in
                //
            }
            
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { (a) in
                self.showIndicator(message: nil)
                let options = [
                    "id" : self.article?.id,
                    "info": self.article?.info
                ]
                
                YasumiService.shared.apiPost(path: "/chatwork/api/deleteRequest" , options: options as! [String : String], success: { (res) in
                    self.hideIndicator()

                    let alert = UIAlertController(title: "Success", message: "Delete success", preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (res) in

                        // post notification when post success to reload home data
                        NotificationCenter.default.post(name: Notification.Name("postSuccess"), object: nil)

                        // back previous screen
                        self.navigationController?.popViewController(animated: true)
                    }))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }, error: { (err) in
                    // error
                })
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (a) in
                //
            }
            alertVC.addAction(editAction)
            alertVC.addAction(deleteAction)
            alertVC.addAction(cancelAction)
            
            self.present(alertVC, animated: true, completion: nil)

        }
    }
    
    // update notification number tabbar
    private func updateTabBarBadgeValue() {
        if let tabItems = self.tabBarController?.tabBar.items {
            // In this case we want to modify the badge number of the third tab:
            let tabItem = tabItems[4]
            let currentBadgeValue = Int(tabItem.badgeValue!)!
            tabItem.badgeValue = String(currentBadgeValue - 1)
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
            cell.selectionStyle = .none
            
            let s = article!.status
            if s == "APPROVED" || s == "approved" {
                cell.backgroundColor = UIColor(red: 78 / 255, green: 207 / 255, blue: 108 / 255, alpha: 0.15)
            } else if s == "DENY" || s == "deny" || s == "DENIED" || s == "denied" {
                cell.backgroundColor = UIColor(red: 1, green: 162 / 255, blue: 140 / 255, alpha: 0.15)
            } else {
                cell.backgroundColor = UIColor.white
            }
            
            let avatarImgView = cell.contentView.viewWithTag(2000) as! UIImageView
            avatarImgView.sd_setImage(with: URL(string: article?.author?.avatar ?? ""), completed: nil)
            
            let nameLabel = cell.contentView.viewWithTag(2001) as! UILabel
            nameLabel.text = article?.author?.name ?? "-"
            
            let emotionLabel = cell.contentView.viewWithTag(2002) as! UILabel
            emotionLabel.text = "feeling " + (article?.emotion ?? "-")
            
            let timerLabel = cell.contentView.viewWithTag(2003) as! UILabel
            timerLabel.text = article?.createAt ?? "-"
            
            // Waiting
            let waitingLabel = cell.contentView.viewWithTag(2008) as! UILabel
            waitingLabel.text = article?.status ?? "-"
            
            // Off / leave
            let typeLabel = cell.contentView.viewWithTag(2004) as! UILabel
            let durationLabel = cell.contentView.viewWithTag(2005) as! UILabel
            
            if article!.info == "leave" {
                typeLabel.text = "Would like to ask for \(article!.check ?? "-")"
                
                var start = article!.start ?? "-"
                if start.count > 3 {
                    let endIndex = start.index(start.endIndex, offsetBy: -3)
                    start = start.substring(to: endIndex)
                }
                
                var end = article!.end ?? "-"
                if end.count > 3 {
                    let endIndex = end.index(end.endIndex, offsetBy: -3)
                    end = end.substring(to: endIndex)
                }
                
                durationLabel.text = start + " -> " + end
            } else {
                typeLabel.text = "Would like to ask for off:"
                
                durationLabel.text = article!.date ?? "-"
            }
            
            let resonLable = cell.contentView.viewWithTag(2007) as! UILabel
            resonLable.text = article?.reason ?? "-"
            
            // Show / hide option button
            let optionImageView = cell.contentView.viewWithTag(2009) as! UIImageView

            if article?.userId == Yasumi.session?.id || Yasumi.session!.role == .admin {
                optionImageView.isHidden = false
                let singleTap = UITapGestureRecognizer(target: self, action: #selector(optionTapped))
                optionImageView.addGestureRecognizer(singleTap)
            } else {
                optionImageView.isHidden = true
            }
            
            let leftLabel = cell.contentView.viewWithTag(2010) as! UILabel
            leftLabel.text = article!.dayLeft ?? "0"
            
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
    
    func showIndicator(message: String?) {
        let data = ActivityData(size: CGSize(width: 30, height: 30),
                                message: message,
                                messageFont: nil,
                                type: .ballBeat,
                                color: nil,
                                padding: nil,
                                displayTimeThreshold: nil,
                                minimumDisplayTime: 0,
                                backgroundColor: nil,
                                textColor: nil)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(data, nil)
    }
    
    func hideIndicator() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
    }
    
}
