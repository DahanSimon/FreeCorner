//
//  AccountSettingsViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 28/12/2021.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AccountSettingsViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var streetNumberTextField: UITextField!
    @IBOutlet weak var streetNameTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var cityNameTextField: UITextField!
    
    
    let userRef = Database.database().reference(withPath: "users")
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id = Auth.auth().currentUser?.uid, let user = FireBaseService.users[id] {
            self.userId = id
            let fullName = user.name.components(separatedBy: " ")
            let adress = user.address["Road Name"]?.components(separatedBy: " ")
            self.nameTextField.text = fullName[0]
            self.lastNameTextField.text = fullName[1]
            self.emailTextField.text = user.email
            self.phoneNumberTextField.text = user.phone
            self.streetNumberTextField.text = adress![0]
            self.streetNameTextField.text = adress?.dropFirst().joined(separator: " ")
            self.zipCodeTextField.text = user.address["Postal Code"]
            self.cityNameTextField.text = user.address["City Name"]
        }
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, let firstName = nameTextField.text, let lastName = lastNameTextField.text, let phoneNumber = phoneNumberTextField.text, let streetNumber = streetNumberTextField.text, let streetName = streetNameTextField.text, let zipCode = zipCodeTextField.text, let cityName = cityNameTextField.text,let id = userId else {
            presentAlert(title: "Oups", message: "Something is wrong with your entries !")
            return
        }
        FireBaseService().populateUser(id: id, name: firstName + " " + lastName, phone: phoneNumber, address: ["Road Name": streetNumber + " " + streetName,"Postal Code": zipCode,"City Name": cityName], offer: nil, email: email)
        self.presentAlert(title: "Oups", message: "Account Updated !")
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        guard let email = FireBaseService.users[userId!]?.email else {
            self.presentAlert(title: "Oups", message: "Something Went Wrong")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let errorDescription = error?.localizedDescription {
                self.presentAlert(title: "Oups", message: errorDescription)
                return
            } else {
                self.presentAlert(title: "Oups", message: "An email just as been sent to you to reset your password")
            }
            
        }
    }
    private func presentAlert(title: String,message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
}