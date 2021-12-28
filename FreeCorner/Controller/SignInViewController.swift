//
//  SignInViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 23/12/2021.
//

import UIKit
import FirebaseAuth
class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.presentAlert(title: "error", message: error.localizedDescription)
                print(error.localizedDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func presentAlert(title: String,message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
}
