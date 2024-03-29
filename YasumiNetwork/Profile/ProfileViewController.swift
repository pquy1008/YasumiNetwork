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
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var viewStaffButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profile = Yasumi.session

        nameTextField.text = profile?.name ?? "-"
        avatarImageView.sd_setImage(with: URL(string: profile?.avatar ?? ""), completed: nil)
        dobTextField.text = profile?.dob ?? "-"
        countryTextField.text = profile?.country ?? "-"
        addressTextField.text = profile?.address ?? "-"
        quoteTextView.textContainerInset = UIEdgeInsets.zero
        quoteTextView.textContainer.lineFragmentPadding = 0
        quoteTextView.text = profile?.quote ?? "-"
        
        if Yasumi.session!.role == .manager {
            viewStaffButton.isHidden = false
        } else {
            viewStaffButton.isHidden = true
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showHistoryTapped(_ sender: Any) {
        let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "historyBoard")
        self.navigationController?.pushViewController(historyVC!, animated: true)
    }
    
    @IBAction func showStaffTapped(_ sender: UIButton) {
        let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "userHistoryBoard")
        self.navigationController?.pushViewController(historyVC!, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {

        // Hide keyboard
        self.view.endEditing(true)
        
        let options = [
            "id": profile!.id,
            "birthday": dobTextField.text ?? "",
            "country":  countryTextField.text ?? "",
            "address":  addressTextField.text ?? "",
            "description": quoteTextView.text ?? "",
            "name": nameTextField.text ?? ""
        ]
        
        YasumiService.shared.apiUpdateProfile(options: options) {
            // Update session
            Yasumi.session?.dob = self.dobTextField.text ?? ""
            Yasumi.session?.country = self.countryTextField.text ?? ""
            Yasumi.session?.address = self.addressTextField.text ?? ""
            Yasumi.session?.quote = self.quoteTextView.text ?? ""
            Yasumi.session?.name = self.nameTextField.text ?? ""
            
            let alertVC = UIAlertController(title: "Update success", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (a) in
                self.dismiss(animated: true, completion: nil)
            })
            
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Are you sure you want logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (res) in
            Yasumi.session = nil
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginViewController")
            
            self.present(vc, animated: false, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
