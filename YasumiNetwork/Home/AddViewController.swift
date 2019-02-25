//
//  AddViewController.swift
//  YasumiNetwork
//
//  Created by Huan CAO on 1/24/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import Foundation
import UIKit

class AddViewController: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    lazy var yasumiViewController: YasumiViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "YasumiViewController") as! YasumiViewController
        
        self.addViewControllerAsChildViewController(childViewController: viewController)
        
        return viewController
    }()
    
    lazy var leaveViewController: LeaveViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "LeaveViewController") as! LeaveViewController
        
        self.addViewControllerAsChildViewController(childViewController: viewController)
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notification()
        setupView()
    }
    
    func notification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.notificationListener(notification:)),
            name: NSNotification.Name(rawValue: "sendData"),
            object: nil)
    }
    
    @objc func notificationListener(notification: NSNotification) {
        var data = notification.userInfo! as! [String: String]
        
        if segmentedControl.selectedSegmentIndex == 0 {
            var dataSubmit : [String: String] = [:]
            
            if (data["reason"] == "" || data["emotion"] == "" || data["type"] == "" || data["firstDay"] == "" || data["inFirstDay"] == ""){
                print("error")
            } else {
                if data["secondDay"] == "" && data["thirdDay"] == "" {
                    dataSubmit = [
                        "duration": "1",
                        "type": data["type"]!,
                        "dates": "\(data["firstDay"]!)-\(data["inFirstDay"]!)",
                        "reason": data["reason"]!,
                        "emotion": data["emotion"]!
                    ]
                } else if data["secondDay"] != "" && data["thirdDay"] == "" {
                    dataSubmit = [
                        "duration": "2",
                        "type": data["type"]!,
                        "dates": "\(data["firstDay"]!)-\(data["inFirstDay"]!),\(data["secondDay"]!)-\(data["inSecondDay"]!)",
                        "reason": data["reason"]!,
                        "emotion": data["emotion"]!
                    ]
                } else if data["secondDay"] != "" && data["thirdDay"] != "" {
                    dataSubmit = [
                        "duration": "3",
                        "type": data["type"]!,
                        "dates": "\(data["firstDay"]!)-\(data["inFirstDay"]!),\(data["secondDay"]!)-\(data["inSecondDay"]!),\(data["thirdDay"]!)-\(data["inThirdDay"]!)",
                        "reason": data["reason"]!,
                        "emotion": data["emotion"]!
                    ]
                } else {
                    print("error")
                }
                
                YasumiService.shared.apiPost(path: "/chatwork/api/addOff", options: dataSubmit, success: { (res) in
                    print("done")
                }) { (err) in
                    print("err")
                }
            }
        } else if segmentedControl.selectedSegmentIndex == 1 {
            print(data)
            
            var leaveData : [String: String] = [:]
            
            if (data["reason"] == "" || data["emotion"] == "" || data["start_time"] == "" || data["end_time"] == "" || data["date"] == "") {
                print("error")
            } else {
                leaveData = [
                    "reason": data["reason"]!,
                    "emotion": data["emotion"]!,
                    "start": data["start_time"]!,
                    "end": data["end_time"]!,
                    "date": data["date"]!
                ]
                
                YasumiService.shared.apiPost(path: "/chatwork/api/addLeave", options: leaveData, success: { (res) in
                    print("done")
                }) { (err) in
                    print("err111")
                }
            }
        }
    }
    
    func setupView() {
        setupSegmentedControl()
        
        updateView()
    }
    
    private func updateView() {
        yasumiViewController.view.isHidden = !(segmentedControl.selectedSegmentIndex == 0)
        leaveViewController.view.isHidden = !(segmentedControl.selectedSegmentIndex == 1)
    }
    
    func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Yasumi", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Leave", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(sender:)), for: .valueChanged)
        
        segmentedControl.selectedSegmentIndex = 0
    }
    
    @objc func selectionDidChange(sender: UISegmentedControl) {
        updateView()
    }
    
    private func addViewControllerAsChildViewController(childViewController: UIViewController) {
        addChild(childViewController)
        
        self.viewContainer.addSubview(childViewController.view)
        
        childViewController.view.frame = view.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        childViewController.didMove(toParent: self)
    }
    
    @IBAction func sendSubmit(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            NotificationCenter.default.post(name: Notification.Name("sendYasumiData"), object: nil)
        } else if segmentedControl.selectedSegmentIndex == 1 {
            NotificationCenter.default.post(name: Notification.Name("sendLeaveData"), object: nil)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
