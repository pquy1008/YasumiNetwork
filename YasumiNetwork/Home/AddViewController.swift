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
        // data
        
        print(notification.userInfo)
        var data = notification.userInfo!
        
        var dataFormat = ["type": data["type"]!, "dates": data["firstDay"]!, "reason": data["reason"]!, "emotion": data["emotion"]!]
        print(dataFormat)
        
        if (dataFormat["type"]! == nil) {
            print("error")
        } else {
            print(dataFormat["type"]!)
        }
        
        
//        let data = [
//            "duration": "1",
//            "type": "1",
//            "dates": "2019/12/20",
//            "reason": "weding",
//            "emotion": "happy"
//        ]
//
//        YasumiService.shared.apiPost(path: "/chatwork/api/addOff", options: data, success: { (res) in
//            print("Done")
//        }) { (err) in
//            print("1")
//        }
        
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
        NotificationCenter.default.post(name: Notification.Name("sendSubmit"), object: nil)
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
}
