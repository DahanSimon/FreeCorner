//
//  SuccessViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 19/12/2021.
//

import UIKit

class SuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    deinit {
        print("success post deinited")
    }
}
