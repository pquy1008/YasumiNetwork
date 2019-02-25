//
//  UserHistoryViewController.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 2/25/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class UserHistoryViewController: UIViewController {

    var users = [User]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.leftViewMode = .always
        searchTextField.leftView = UIImageView(image: UIImage(named: "search"))
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let value = textField.text ?? ""
        
        if value == "" {
            users = [User]()
            tableView.reloadData()
        } else {
            users = Yasumi.userLst.filter { (u) -> Bool in
                return (u.name?.contains(value) ?? false) || (u.email?.contains(value) ?? false)
            }
            tableView.reloadData()
        }
    }
}

extension UserHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        
        let avatarImageView = cell.contentView.viewWithTag(1000) as! UIImageView
        let nameLabel = cell.contentView.viewWithTag(1001) as! UILabel
        let addressLable = cell.contentView.viewWithTag(1002) as! UILabel
        
        avatarImageView.sd_setImage(with: URL(string: users[indexPath.row].avatar ?? ""), completed: nil)
        nameLabel.text = users[indexPath.row].name
        addressLable.text = users[indexPath.row].address
        
        cell.separatorInset = UIEdgeInsets.zero
        return cell
    }
}


