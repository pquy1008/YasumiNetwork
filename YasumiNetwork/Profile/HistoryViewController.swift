//
//  HistoryViewController.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 2/20/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    
    var userProfile: User?

    var off = [Feed]()
    var leave = [Feed]()
    var dataSource = [Feed]()
    
    var isOffSelected: Bool = true
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userProfile == nil {
            userProfile = Yasumi.session
        }
        
        let optiosn = [
            "id": userProfile!.id
        ]
        YasumiService.shared.apiGetHistory(options: optiosn) { (off, leave) in
            self.off = off
            self.leave = leave
            
            // Off as default
            self.dataSource = self.off
            
            self.tableView.reloadData()
        }
    }
    
    func refresh() {
        let optiosn = [
            "id": userProfile!.id
        ]
        YasumiService.shared.apiGetHistory(options: optiosn) { (off, leave) in
            self.off = off
            self.leave = leave
            
            if self.isOffSelected {
                self.dataSource = self.off
            } else {
                self.dataSource = self.leave
            }
            
            self.tableView.reloadData()
        }
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            dataSource = off
            isOffSelected = true
        case 1:
            dataSource = leave
            isOffSelected = false
        default:
            break
        }
        
        tableView.reloadData()
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < 2 { return }
        
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "detailBoard") as! YasumiDetailViewController
        detailVC.article = dataSource[indexPath.row - 2]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets.zero

            let avatarImageView = cell.contentView.viewWithTag(1000) as? UIImageView
            avatarImageView?.sd_setImage(with: URL(string: userProfile?.avatar ?? ""), completed: nil)
            
            let nameTextField = cell.contentView.viewWithTag(1001) as? UITextField
            nameTextField?.text = userProfile?.name ?? "-"
            
            let doLTextField = cell.contentView.viewWithTag(1002) as? UITextField
            doLTextField?.text = userProfile?.dol ?? "-"
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "controlCell", for: indexPath)
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets.zero

            let segmentControll = cell.contentView.viewWithTag(1003) as? UISegmentedControl
            segmentControll?.addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for: .valueChanged)
        default:
            
            if isOffSelected {
                cell = tableView.dequeueReusableCell(withIdentifier: "offCell", for: indexPath)
                
                let timeLabelView = cell.contentView.viewWithTag(1000) as? UILabel
                timeLabelView?.text = "in " + (dataSource[indexPath.row - 2].createAt ?? "-")
                
                let dateLabel = cell.contentView.viewWithTag(1001) as? UILabel
                dateLabel?.text = dataSource[indexPath.row - 2].date ?? "-"
                
                let resonLable = cell.contentView.viewWithTag(1002) as? UILabel
                resonLable?.text = dataSource[indexPath.row - 2].reason ?? "-"
                
                let statusLabel = cell.contentView.viewWithTag(1003) as? UILabel
                statusLabel?.text = dataSource[indexPath.row - 2].status ?? "-"
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "leaveCell", for: indexPath)
                
                let timeLabelView = cell.contentView.viewWithTag(1000) as? UILabel
                timeLabelView?.text = "in " + (dataSource[indexPath.row - 2].createAt ?? "-")
                
                let dateLabel = cell.contentView.viewWithTag(1001) as? UILabel
                dateLabel?.text = dataSource[indexPath.row - 2].date ?? "-"
                
                let resonLable = cell.contentView.viewWithTag(1002) as? UILabel
                resonLable?.text = dataSource[indexPath.row - 2].reason ?? "-"
                
                let fromLabel = cell.contentView.viewWithTag(1003) as? UILabel
                fromLabel?.text = dataSource[indexPath.row - 2].start ?? "-"
                
                let toLabel = cell.contentView.viewWithTag(1004) as? UILabel
                toLabel?.text = dataSource[indexPath.row - 2].end ?? "-"
                
                let statusLabel = cell.contentView.viewWithTag(1005) as? UILabel
                statusLabel?.text = dataSource[indexPath.row - 2].status ?? "-"
            }
            
            let s = dataSource[indexPath.row - 2].status
            if s == "APPROVED" || s == "approved" {
                cell.backgroundColor = UIColor(red: 78 / 255, green: 207 / 255, blue: 108 / 255, alpha: 0.15)
            } else if s == "DENY" || s == "deny" || s == "DENIED" || s == "denied" {
                cell.backgroundColor = UIColor(red: 1, green: 162 / 255, blue: 140 / 255, alpha: 0.15)
            } else {
                cell.backgroundColor = UIColor.white
            }
        }

        cell.selectionStyle = .none
        return cell
    }
}
