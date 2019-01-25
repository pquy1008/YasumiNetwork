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
    
    @IBOutlet weak var dateTimeTextField: UITextField!
    
    var currentTextField = UITextField()
    
    var pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    
    var reasons: [String] = ["I feel not fine", "I have private reason", "other"]
    var emotions: [String] = ["happy", "sad", "afraid"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func datePickerValueChange(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        
        dateTimeTextField.text = formatter.string(from: sender.date)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextField == reasonTextField {
            return reasons[row]
        } else if currentTextField == emotionTextField {
            return emotions[row]
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
        } else if currentTextField == dateTimeTextField {
            print("1")
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(datePickerValueChange(sender:)), for: .valueChanged)
            dateTimeTextField.inputView = datePicker
        }
    }
    
    @IBAction func reasonDropDownBtnAction(_ sender: Any) {
        self.reasonTextField.becomeFirstResponder()
    }
    
    @IBAction func emotionDropDownBtnAction(_ sender: Any) {
        self.emotionTextField.becomeFirstResponder()
    }
    
    // MARK: - TEST
    
    
}
