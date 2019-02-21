//
//  YasumiViewController.swift
//  YasumiNetwork
//
//  Created by Huan CAO on 1/24/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class YasumiViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var emotionTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var inDayTextField: UITextField!
    @IBOutlet weak var dateTimeTextField: UITextField!
    
    // for case: add more day
    @IBOutlet weak var dayOneStackView: UIStackView!
    @IBOutlet weak var dayOneLineBreakStackView: UIStackView!
    @IBOutlet weak var dayTwoStackView: UIStackView!
    @IBOutlet weak var dayTwoLineBreakStackView: UIStackView!
    
    @IBOutlet weak var dayOneDateTimeTextField: UITextField!
    @IBOutlet weak var dayOneInDayTextField: UITextField!
    
    @IBOutlet weak var dayTwoDateTimeTextField: UITextField!
    @IBOutlet weak var dayTwoInDayTextField: UITextField!
    
    @IBOutlet weak var oneMoreDayButton: UIButton!
    
    var clickCount = 0
    var dateTimeIndex = 0
    
    var currentTextField = UITextField()

    var pickerView = UIPickerView()
    let datePicker = UIDatePicker()

    var reasons: [String] = ["I feel not fine", "I have private reason", "other"]
    var emotions: [String] = ["happy", "sad", "afraid"]
    var types: [String] = ["Sick Leave", "Private Leave", "Annual Leave", "Compensation Work", "Suckle a Baby"]
    var inDays: [String] = ["ALL", "AM", "PM"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notification()
    }
    
    func notification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.notificationListener(notification:)),
            name: NSNotification.Name(rawValue: "sendSubmit"),
        object: nil)
    }
    
    @objc func notificationListener(notification: NSNotification) {
        let yasumiData = ["reason": reasonTextField.text, "emotion": emotionTextField.text, "type": typeTextField.text, "firstDay": dateTimeTextField.text, "inFirstDay": inDayTextField.text, "secondDay": dayOneDateTimeTextField.text, "inSecondDay": dayOneInDayTextField.text, "thirdDay": dayTwoDateTimeTextField.text, "inThirdDay": dayTwoInDayTextField.text]
        NotificationCenter.default.post(name: Notification.Name("sendData"), object: nil, userInfo: yasumiData as [AnyHashable : Any])
    }

    // MARK: - Picker View
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentTextField == reasonTextField {
            return reasons.count
        } else if currentTextField == emotionTextField {
            return emotions.count
        } else if currentTextField == typeTextField {
          return types.count
        } else if currentTextField == inDayTextField {
            return inDays.count
        }else if currentTextField == dayOneInDayTextField {
            return inDays.count
        } else if currentTextField == dayTwoInDayTextField {
            return inDays.count
        } else {
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextField == reasonTextField {
            return reasons[row]
        } else if currentTextField == emotionTextField {
            return emotions[row]
        } else if currentTextField == typeTextField {
            return types[row]
        } else if currentTextField == inDayTextField {
            return inDays[row]
        } else if currentTextField == dayOneInDayTextField {
            return inDays[row]
        } else if currentTextField == dayTwoInDayTextField {
            return inDays[row]
        } else {
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentTextField == reasonTextField {
            reasonTextField.text = reasons[row]
            self.view.endEditing(true)
        } else if currentTextField == emotionTextField {
            emotionTextField.text = emotions[row]
            self.view.endEditing(true)
        } else if currentTextField == typeTextField {
            typeTextField.text = types[row]
            self.view.endEditing(true)
        } else if currentTextField == inDayTextField {
            inDayTextField.text = inDays[row]
        } else if currentTextField == dayOneInDayTextField {
            dayOneInDayTextField.text = inDays[row]
        } else if currentTextField == dayTwoInDayTextField {
            dayTwoInDayTextField.text = inDays[row]
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        let textFieldArray = [reasonTextField, emotionTextField, typeTextField, inDayTextField, dayOneInDayTextField, dayTwoInDayTextField]
        currentTextField = textField

        if textFieldArray.contains(currentTextField) {
            currentTextField.inputView = pickerView
        } else if currentTextField == dateTimeTextField {
            dateTimeIndex = 0
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(datePickerValueChange(sender:)), for: .valueChanged)
            dateTimeTextField.inputView = datePicker
        } else if currentTextField == dayOneDateTimeTextField {
            dateTimeIndex = 1
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(datePickerValueChange(sender:)), for: .valueChanged)
            dayOneDateTimeTextField.inputView = datePicker
        } else if currentTextField == dayTwoDateTimeTextField {
            dateTimeIndex = 2
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(datePickerValueChange(sender:)), for: .valueChanged)
            dayTwoDateTimeTextField.inputView = datePicker
        }
    }

    @objc func datePickerValueChange(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none

        if dateTimeIndex == 0 {
            dateTimeTextField.text = formatter.string(from: sender.date)
        } else if dateTimeIndex == 1 {
            dayOneDateTimeTextField.text = formatter.string(from: sender.date)
        } else if dateTimeIndex == 2 {
            dayTwoDateTimeTextField.text = formatter.string(from: sender.date)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func oneMoreDayAction(_ sender: Any) {
        if clickCount == 0 {
            dayOneStackView.isHidden = false
            dayOneLineBreakStackView.isHidden = false
            clickCount += 1
        } else if clickCount == 1 {
            dayTwoStackView.isHidden = false
            dayTwoLineBreakStackView.isHidden = false
            
            oneMoreDayButton.isEnabled = false
        }
    }
    
    
}

