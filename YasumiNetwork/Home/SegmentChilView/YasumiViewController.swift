//
//  YasumiViewController.swift
//  YasumiNetwork
//
//  Created by Huan CAO on 1/24/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit

class YasumiViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var emotionTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var inDayTextField: UITextField!
    
    @IBOutlet weak var otherReasonTextField: UITextField!
    
    @IBOutlet weak var dateTimeTextField: UITextField!
    
    var currentTextField = UITextField()
    
    var pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    
    var reasons: [String] = ["I feel not fine", "I have private reason", "other"]
    var emotions: [String] = ["happy", "sad", "afraid"]
    var types: [String] = ["Sick Leave", "Private Leave", "Annual Leave", "Compensation Work", "Suckle a Baby"]
    var inDays: [String] = ["ALL", "AM", "PM"]

    override func viewDidLoad() {
        super.viewDidLoad()
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
        }else {
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
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.otherReasonTextField.isHidden = true
        
        if currentTextField == reasonTextField {
            reasonTextField.text = reasons[row]
            
            if reasonTextField.text == "other" {
                self.otherReasonTextField.isHidden = false
            }
        } else if currentTextField == emotionTextField {
            emotionTextField.text = emotions[row]
        } else if currentTextField == typeTextField {
            typeTextField.text = types[row]
        } else if currentTextField == inDayTextField {
            inDayTextField.text = inDays[row]
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        currentTextField = textField
        if currentTextField == reasonTextField {
            currentTextField.inputView = pickerView
        } else if currentTextField == emotionTextField {
            currentTextField.inputView = pickerView
        } else if currentTextField == typeTextField {
            currentTextField.inputView = pickerView
        } else if currentTextField == inDayTextField{
            currentTextField.inputView = pickerView
        } else if currentTextField == dateTimeTextField {
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(datePickerValueChange(sender:)), for: .valueChanged)
            dateTimeTextField.inputView = datePicker
        }
    }
    
    @objc func datePickerValueChange(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        
        dateTimeTextField.text = formatter.string(from: sender.date)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - TEST
    
    
}
