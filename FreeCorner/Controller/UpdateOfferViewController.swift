//
//  UpdateOfferViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 25/12/2021.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseAuth

protocol UpdateOfferDelegate {
    func didUpdateOffer(name: String, id: Int, description: String, images: [String], owner: String, category: String)
}

class UpdateOfferViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    var updateOfferDelegate: UpdateOfferDelegate!
    var selectedOffer: Offer?
    var usersOffersIds: [String]?
    let offerRef = Database.database().reference(withPath: "offers")
    let userRef = Database.database().reference(withPath: "users")
    let userId = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(PhotosListCollectionViewCell.nib(), forCellWithReuseIdentifier: "PhotosListCollectionViewCell")
        nameTextField.text = selectedOffer?.name
        descriptionTextField.text = selectedOffer?.desctiption
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, let description = descriptionTextField.text, let selectedOffer = selectedOffer  else {
            return
        }
        
        updateOfferDelegate.didUpdateOffer(name: name, id: Int(selectedOffer.key)!, description: description, images: selectedOffer.images, owner: userId!, category: Categories.allCases[categoryPickerView.selectedRow(inComponent: 0)].rawValue)
        self.dismiss(animated: true, completion: nil)
    }
}
extension UpdateOfferViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ((selectedOffer?.images.count)! + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosListCollectionViewCell", for: indexPath) as? PhotosListCollectionViewCell,let selectedOffer = selectedOffer else {
            return UICollectionViewCell()
        }
        if selectedOffer.images.count > indexPath.row {
            cell.configure(imageUrl:selectedOffer.images[indexPath.row],index: indexPath.row, offersId: selectedOffer.key)
        } else {
            cell.showAddImageButton()
        }
        return cell
    }
}

extension UpdateOfferViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Categories.allCases.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Categories.allCases[row].rawValue
    }
}
