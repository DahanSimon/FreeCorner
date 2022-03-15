//
//  SettingsMenuViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 27/12/2021.
//

import UIKit
import FirebaseAuth

class SettingsMenuViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var myOffersButton: UIButton!
    @IBOutlet weak var accountSettingsButton: UIButton!
    @IBOutlet weak var logButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        isUserConnected()
    }

    // MARK: Overrides
    override func viewWillAppear(_ animated: Bool) {
        isUserConnected()
        FireBaseService.shared.testConnection { isConnected in
            if !isConnected {
                self.presentAlert(title: "No Connection", message: "Please come back whe you will have \n a good network connection.")
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SignUpViewController {
            controller.completionHandler = {
//                self.isUserConnected()
            }
        }
    }
    
    // MARK: Actions
    @IBAction func logOut(_ sender: UIButton) {
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "settingsToLoginSegue", sender: self)
        }
        myOffersButton.isHidden = true
        accountSettingsButton.isHidden = true
        logButton.setTitle("Log In", for: .normal)
        try? Auth.auth().signOut()
    }
    
    // MARK: Methods
    private func isUserConnected() {
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "settingsToLoginSegue", sender: self)
            myOffersButton.isHidden = true
            accountSettingsButton.isHidden = true
            logButton.setTitle("Log In", for: .normal)
        } else {
            self.dismiss(animated: true, completion: nil)
            myOffersButton.isHidden = false
            accountSettingsButton.isHidden = false
            logButton.setTitle("Log Out", for: .normal)
        }
    }
    
    private func presentAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
}
