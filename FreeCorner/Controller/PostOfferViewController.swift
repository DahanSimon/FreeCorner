//
//  PostOfferViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 19/12/2021.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseAuth
import OpalImagePicker
import Photos
import SwiftUI

class PostOfferViewController: UIViewController{
    //MARK: Variables
    var usersOffersIds: [String: String] {
        guard let id = Auth.auth().currentUser?.uid, let usersOffers = FireBaseService.users[id]?.offer else {
            return [:]
        }
        return usersOffers
    }
    let offersRef                       = Database.database().reference(withPath: "offers")
    let usersRef                        = Database.database().reference(withPath: "users")
    var refObservers: [DatabaseHandle]  = []
    let storage                         = Storage.storage().reference()
    var offerImages: [UIImage]          = []
    var imagesUrl: [String]             = []
    var offerName: String?
    var offerDescription: String?
    var category: Category?
    var offers: [String: Offer] {
        return FireBaseService.offers
    }
    
    
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sendOfferButton: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendOfferButton.isHidden = true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SignUpViewController {
            controller.completionHandler = {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "signUpSegue", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(addImageNotificationReceived), name: Notification.Name("addImagePostOffer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived(_:)), name: Notification.Name("deletedImagePostOffer"), object: nil)
        collectionView.register(PhotosListCollectionViewCell.nib(), forCellWithReuseIdentifier: "PhotosListCollectionViewCell")
        FireBaseService.getOffers { _ in }
    }
    //MARK: Actions
    @objc func notificationReceived(_ notification: NSNotification) {
        let index = notification.object as! Int
            imagesUrl.remove(at: index)
            collectionView.reloadData()
            if imagesUrl.isEmpty {
                sendOfferButton.isHidden = true
            }
    }
    @objc func addImageNotificationReceived() {
        if self.isViewLoaded {
            let picker              = OpalImagePickerController()
            let previousImagesCount = offerImages.count
            presentOpalImagePickerController(picker, animated: true) { assets in
                picker.dismiss(animated: true) {
                    for asset in assets {
                        self.offerImages.append(self.getAssetThumbnail(asset: asset, size: 4000))
                    }
                    for i in previousImagesCount..<self.offerImages.count {
                        self.sendData(image: self.offerImages[i], index: i)
                    }
                    self.sendOfferButton.isHidden = true
                }
            } cancel: { }
        }
    }
    @IBAction func sendOfferButtonTapped(_ sender: Any) {
        guard let user = Auth.auth().currentUser?.uid, let name = nameTextField.text, let description = descriptionTextField.text, let idInt = Int(getNewImageId()) else {
            return
        }
        var offers = self.usersOffersIds
        offers[String(idInt + 1)] = name
        self.usersRef.child("\(user)/offers").setValue(offers)
        let category = Categories.allCases[categoryPickerView.selectedRow(inComponent: 0)]
        FireBaseService().populateOffer(id: idInt + 1, name: name, description: description, images: imagesUrl, owner: user, category: category.rawValue)
        
        reset()
    }
    
    //MARK: Methods
    func sendData(image: UIImage, index: Int) {
        guard let imageData = image.pngData() else {
            return
        }
        storage.child("images/\(self.offers.count)/image\(index).png").putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                print("error")
                return
            }
            self.storage.child("images/\(self.offers.count)/image\(index).png").downloadURL { url, error in
                guard let url = url, error == nil else {
                    print("error")
                    return
                }
                let string = url.absoluteString
                self.imagesUrl.append(string)
                self.sendOfferButton.isHidden = false
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
    }
    func getAssetThumbnail(asset: PHAsset, size: CGFloat) -> UIImage {
        let retinaScale            = UIScreen.main.scale
        let retinaSquare           = CGSize(width: size * retinaScale, height: size * retinaScale)
        let cropSizeLength         = min(asset.pixelWidth, asset.pixelHeight)
        let square                 = CGRect(x: 0, y: 0, width: CGFloat(cropSizeLength), height: CGFloat(cropSizeLength))
        let cropRect               = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(asset.pixelWidth), y: 1.0/CGFloat(asset.pixelHeight)))
        let manager                = PHImageManager.default()
        let options                = PHImageRequestOptions()
        var thumbnail              = UIImage()
        options.isSynchronous      = true
        options.deliveryMode       = .highQualityFormat
        options.resizeMode         = .exact
        options.normalizedCropRect = cropRect
        
        manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    func showAlert(Title : String!, Message : String!)  -> UIAlertController {
        let alertController : UIAlertController = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        let okAction : UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (alert) in
            print("User pressed ok function")
            
        }
        alertController.addAction(okAction)
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame
        return alertController
    }
    
    func reset() {
        sendOfferButton.isHidden       = true
        self.nameTextField.text        = ""
        self.offerImages               = []
        self.imagesUrl                 = []
        self.descriptionTextField.text = ""
        collectionView.reloadData()
    }
    
    func getNewImageId() -> String {
        let ids = offers.keys
        var id: String = "0"
        for key in ids {
            if key > id {
                id = key
            }
        }
        return id
    }
}
extension PostOfferViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Categories.allCases.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView.setValue(UIColor(red: 249, green: 251, blue: 178, alpha: 1), forKey: "textColor")
        return Categories.allCases[row].rawValue
    }
}

extension PostOfferViewController:  UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (imagesUrl.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosListCollectionViewCell", for: indexPath) as? PhotosListCollectionViewCell else {
            return UICollectionViewCell()
        }
        if imagesUrl.count > indexPath.row {
            let id = getNewImageId()
            cell.configure(imageUrl: imagesUrl[indexPath.row], index: indexPath.row, offersId: id)
        } else {
            cell.showAddImageButton()
        }
        return cell
    }
}

extension PostOfferViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

