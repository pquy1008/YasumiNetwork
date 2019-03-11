//
//  LeaveViewController.swift
//  YasumiNetwork
//
//  Created by Huan CAO on 1/24/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class LeaveViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var leaveTypeTextField: UITextField!
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var emotionTextField: UITextField!
    @IBOutlet weak var leaveDateTextField: UITextField!
    @IBOutlet weak var leaveFromTextField: UITextField!
    @IBOutlet weak var leaveToTextField: UITextField!
    
    
    var pickerView = UIPickerView()
    var datePicker = UIDatePicker()
    var timePicker = UIDatePicker()
    
    var currentTextField = UITextField()
    
    var timePickerIndex = 0
    
    var leaveTypes: [String] = ["Coming Late", "Leave soon"]
    var reasons: [String] = []
    var emotions: [String] = ["happy", "sad", "afraid"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notification()
        leaveToTextField.isEnabled = false

        // Do any additional setup after loading the view.
    }
    
    func notification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.notificationListener(notification:)),
            name: NSNotification.Name(rawValue: "sendLeaveData"),
            object: nil)
    }
    
    @objc func notificationListener(notification: NSNotification) {
        let leaveData = [
                "reason": reasonTextField.text!,
                "emotion": emotionTextField.text!,
                "date": leaveDateTextField.text!,
                "start_time": leaveFromTextField.text!,
                "end_time": leaveToTextField.text!,
        ]
        
        NotificationCenter.default.post(name: Notification.Name("sendData"), object: nil, userInfo: leaveData)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch currentTextField {
        case leaveTypeTextField:
            return leaveTypes.count
        case reasonTextField:
            return reasons.count
        case emotionTextField:
            return emotions.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch currentTextField {
        case leaveTypeTextField:
            return leaveTypes[row]
        case reasonTextField:
            return reasons[row]
        case emotionTextField:
            return emotions[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch currentTextField {
        case leaveTypeTextField:
            leaveTypeTextField.text = leaveTypes[row]
        case reasonTextField:
            reasonTextField.text = reasons[row]
        case emotionTextField:
            emotionTextField.text = emotions[row]
        default:
            return
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        currentTextField = textField

        switch currentTextField {
        case leaveDateTextField:
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(datePickerValueChange(sender:)), for: .valueChanged)
            leaveDateTextField.inputView = datePicker
        case leaveFromTextField:
            timePickerIndex = 1
            timePicker.datePickerMode = .time
            timePicker.addTarget(self, action: #selector(timePickerValueChange), for: .valueChanged)
            leaveFromTextField.inputView = timePicker
        case leaveToTextField:
            timePickerIndex = 2
            timePicker.datePickerMode = .time
            timePicker.addTarget(self, action: #selector(timePickerValueChange), for: .valueChanged)
            leaveToTextField.inputView = timePicker
        case reasonTextField:
            if leaveTypeTextField.text! == "Coming Late" {
                reasons = ["I feel not fine", "I have private reason"]
            } else if leaveTypeTextField.text! == "Leave soon" {
                reasons = ["I feel not fine", "I have private reason"]
            } else {
                reasons = []
            }
            currentTextField.inputView = pickerView
        default:
            currentTextField.inputView = pickerView
        }
    }
    
    @objc func datePickerValueChange(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        leaveDateTextField.text = formatter.string(from: sender.date)
    }
    
    @objc func timePickerValueChange(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
                
        if timePickerIndex == 1 {
            let min = formatter.date(from: "8:30")
            let max = formatter.date(from: "17:30")
            
            timePicker.minimumDate = min
            timePicker.maximumDate = max
            
            leaveFromTextField.text = formatter.string(from: sender.date)
            leaveToTextField.isEnabled = true
        } else if timePickerIndex == 2 {
            let min = formatter.date(from: leaveFromTextField.text!)
            let max = min?.addingTimeInterval(2*60*60)
            
            let tempMax = formatter.date(from: "17:30")
            timePicker.minimumDate = min
            timePicker.maximumDate = max
            
            let compareResult = max!.compare(tempMax!)
            if compareResult == ComparisonResult.orderedDescending {
                timePicker.maximumDate = tempMax
            } else {
                timePicker.maximumDate = max
            }
            
            leaveToTextField.text = formatter.string(from: sender.date)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
