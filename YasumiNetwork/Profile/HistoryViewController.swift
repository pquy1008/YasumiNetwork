//
//  HistoryViewController.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 2/20/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    var off = [Feed]()
    var leave = [Feed]()
    var dataSource = [Feed]()
    
    var isOffSelected: Bool = true
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let optiosn = [
            "id": Yasumi.session?.id ?? ""
        ]
        YasumiService.shared.apiGetHistory(options: optiosn) { (off, leave) in
            self.off = off
            self.leave = leave
            
            // Off as default
            self.dataSource = self.off
            
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets.zero

            let avatarImageView = cell.contentView.viewWithTag(1000) as? UIImageView
            avatarImageView?.sd_setImage(with: URL(string: Yasumi.session?.avatar ?? ""), completed: nil)
            
            let nameTextField = cell.contentView.viewWithTag(1001) as? UITextField
            nameTextField?.text = Yasumi.session?.name ?? "-"
            
            let doLTextField = cell.contentView.viewWithTag(1002) as? UITextField
            doLTextField?.text = Yasumi.session?.dol ?? "-"
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "controlCell", for: indexPath)
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets.zero

            let segmentControll = cell.contentView.viewWithTag(1003) as? UISegmentedControl
            segmentControll?.addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for: .valueChanged)
            
            return cell
        default:
            
            if isOffSelected {
                let cell = tableView.dequeueReusableCell(withIdentifier: "offCell", for: indexPath)
                
                let timeLabelView = cell.contentView.viewWithTag(1000) as? UILabel
                timeLabelView?.text = "in " + (dataSource[indexPath.row - 2].createAt ?? "-")
                
                let dateLabel = cell.contentView.viewWithTag(1001) as? UILabel
                dateLabel?.text = dataSource[indexPath.row - 2].date ?? "-"
                
                let resonLable = cell.contentView.viewWithTag(1002) as? UILabel
                resonLable?.text = dataSource[indexPath.row - 2].reason ?? "-"
                
                let statusLabel = cell.contentView.viewWithTag(1003) as? UILabel
                statusLabel?.text = dataSource[indexPath.row - 2].status ?? "-"
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "leaveCell", for: indexPath)
                
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
                
                return cell
            }
        }
        
    }
}