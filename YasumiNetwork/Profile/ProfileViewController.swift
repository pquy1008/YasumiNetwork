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
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showHistoryTapped(_ sender: Any) {
        let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "historyBoard")
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
}
