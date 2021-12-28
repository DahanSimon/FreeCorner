//
//  SettingsMenuViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 27/12/2021.
//

import UIKit
import FirebaseAuth

class SettingsMenuViewController: UIViewController {

    @IBOutlet weak var myOffersButton: UIButton!
    @IBOutlet weak var accountSettingsButton: UIButton!
    @IBOutlet weak var logButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser == nil {
            myOffersButton.isHidden = true
            accountSettingsButton.isHidden = true
            logButton.setTitle("Log In", for: .normal)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "settingsToLoginSegue", sender: self)
        } else {
            myOffersButton.isHidden = false
            accountSettingsButton.isHidden = false
            logButton.setTitle("Log Out", for: .normal)
        }
    }
    

    @IBAction func logOut(_ sender: UIButton) {
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "settingsToLoginSegue", sender: self)
        }
        myOffersButton.isHidden = true
        accountSettingsButton.isHidden = true
        logButton.setTitle("Log In", for: .normal)
        try? Auth.auth().signOut()
    }

}
