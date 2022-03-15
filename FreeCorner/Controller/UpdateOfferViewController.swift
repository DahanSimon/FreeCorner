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
import FirebaseStorage

protocol UpdateOfferDelegate: AnyObject {
    func didUpdateOffer(name: String, id: String, description: String, images: [String], owner: String, category: String)
}

class UpdateOfferViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var updateButton: UIButton!
    
    // MARK: Variables
    let storage                 = Storage.storage().reference()
    let offerRef                = Database.database().reference(withPath: "offers")
    let userRef                 = Database.database().reference(withPath: "users")
    let userId                  = Auth.auth().currentUser?.uid
    var offers: [String: Offer] = FireBaseService.shared.offers
    weak var updateOfferDelegate: UpdateOfferDelegate!
    var selectedOfferIndex: String?
    var selectedOffer: Offer?
    var usersOffersIds: [String]?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived(_:)), name: Notification.Name("deletedImage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addImageNotificationReceived), name: Notification.Name("addImage"), object: nil)
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FireBaseService.shared.testConnection { isConnected in
            if !isConnected {
                self.presentAlert(title: "No Connection", message: "Please come back whe you will have \n a good network connection.")
            }
        }
        selectedOffer             = offers[selectedOfferIndex!]
        nameTextField.text        = selectedOffer?.name
        descriptionTextField.text = selectedOffer?.desctiption
        collectionView.register(PhotosListCollectionViewCell.nib(), forCellWithReuseIdentifier: "PhotosListCollectionViewCell")
        self.collectionView.reloadData()
    }
    
    // MARK: Actions
    @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
    }
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, let description = descriptionTextField.text, let selectedOffer = selectedOffer  else {
            return
        }
        
        updateOfferDelegate.didUpdateOffer(name: name,
                                           id: selectedOffer.key,
                                           description: description,
                                           images: selectedOffer.images,
                                           owner: userId!,
                                           category: Categories.allCases[categoryPickerView.selectedRow(inComponent: 0)].rawValue)
        presentAlert(title: "Offer Updated !", message: "Done !")
    }
    @objc func notificationReceived(_ notification: NSNotification) {
        guard let index = notification.object as? Int else {
            return
        }
            selectedOffer?.images.remove(at: index)
            collectionView.reloadData()
    }
    @objc func addImageNotificationReceived() {
        if self.isViewLoaded {
            let picker               = UIImagePickerController()
                picker.allowsEditing = true
                picker.delegate      = self
                present(picker, animated: true)
        }
        
    }
    // MARK: Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        updateButton.isHidden = true
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        guard let imageData = image.pngData(), let offer = self.selectedOffer else {
            return
        }
        StorageService().saveImage(imageData: imageData, offerId: offer.key, index: offer.images.count) { success, url in
            guard let url = url else {
                return
            }
            if success {
                let string = url.absoluteString
                FireBaseService.shared.offers[self.selectedOffer!.key]?.images.append(string)
                self.selectedOffer?.images.append(string)
                self.collectionView.reloadData()
                self.updateButton.isHidden = false
            }
        }
    }
    
    private func presentAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action  = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    deinit {
        print("update offer deinited")
    }
}
extension UpdateOfferViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let offerImagesCount = selectedOffer?.images.count else {
            return 0
        }
        return (offerImagesCount + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosListCollectionViewCell", for: indexPath) as? PhotosListCollectionViewCell,
                let selectedOffer = selectedOffer else {
            return UICollectionViewCell()
        }
        if selectedOffer.images.count > indexPath.row {
            cell.configure(image: nil, imageUrl: selectedOffer.images[indexPath.row], index: indexPath.row, offersId: selectedOffer.key)
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
        return Categories.allCases.count - 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let categories                  = Categories.allCases
        var categoriesToShow: [String]  = []
        for category in categories where category != .all {
            categoriesToShow.append(category.rawValue)
        }
        return categoriesToShow[row]
    }
}
