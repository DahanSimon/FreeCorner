//
//  SignUpViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 22/12/2021.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class SignUpViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var streetNumberTextField: UITextField!
    @IBOutlet weak var streetNameTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let usersRef = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let phoneNumber = phoneNumberTextField.text, let streetNumber = streetNumberTextField.text, let streetName = streetNameTextField.text, let zipCode = zipCodeTextField.text, let cityName = cityNameTextField.text else {
            presentAlert(title: "Oups", message: "Something is wrong with your entries !")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let errorDescription = error?.localizedDescription {
                self.presentAlert(title: "Oups", message: errorDescription)
                return
            }
            guard let id = result?.user.uid else {
                return
            }
            FireBaseService().populateUser(id: id, name: firstName + " " + lastName, phone: phoneNumber, address: ["Road Name": streetNumber + " " + streetName,"Postal Code": zipCode,"City Name": cityName], offer: nil, email: email)
        }
        if Auth.auth().currentUser != nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func signInButtonTapped(_ sender: Any) {
        let signInVC = SignInViewController()
        signInVC.modalPresentationStyle = .fullScreen
        present(signInVC, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func presentAlert(title: String,message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
}
