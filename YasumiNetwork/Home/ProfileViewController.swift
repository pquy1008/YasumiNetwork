//
//  ProfileViewController.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 2/15/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var profile: User?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            // Profile cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
            
            if let avatarImageView = cell.contentView.viewWithTag(1000) as? UIImageView {
                avatarImageView.sd_setImage(with: URL(string: profile?.avatar ?? ""), completed: nil)
            }
            
            if let nameLabel = cell.contentView.viewWithTag(1001) as? UILabel {
                nameLabel.text = profile?.name ?? "-"
            }
            
            if let dobLable = cell.contentView.viewWithTag(1002) as? UILabel {
                dobLable.text = profile?.dob ?? "-"
            }
            
            if let countryLable = cell.contentView.viewWithTag(1003) as? UILabel {
                countryLable.text = profile?.country ?? "-"
            }
            
            if let addressLabel = cell.contentView.viewWithTag(1004) as? UILabel {
                addressLabel.text = profile?.address ?? "-"
            }
            
            if let quoteLable = cell.contentView.viewWithTag(1005) as? UILabel {
                quoteLable.text = profile?.quote ?? "-"
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
            return cell
        }
    }
}
