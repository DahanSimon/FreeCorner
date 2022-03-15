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

class PostOfferViewController: UIViewController {
    // MARK: Variables
    var usersOffersIds: [String: String] {
        guard let id = Auth.auth().currentUser?.uid, let usersOffers = FireBaseService.shared.users[id]?.offers else {
            return [:]
        }
        return usersOffers
    }
    let userId = Auth.auth().currentUser?.uid
    let offersRef                       = Database.database().reference(withPath: "offers")
    let usersRef                        = Database.database().reference(withPath: "users")
    var refObservers: [DatabaseHandle]  = []
    var offerImages: [UIImage]          = []
    var imagesUrl: [String]             = []
    var offerName: String?
    var offerDescription: String?
    var category: Category?
    var offers: [String: Offer] {
        return FireBaseService.shared.offers
    }
    var users: [String: User] {
        return FireBaseService.shared.users
    }
    var offerId = UUID().uuidString
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sendOfferButton: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendOfferButton.isHidden = true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SignUpViewController {
            controller.completionHandler = { [self] in
                self.dismiss(animated: true, completion: nil)
                if Auth.auth().currentUser == nil {
                    presentAlert(title: "You are not logged in", message: "Please create an account or log in \nto publish an offer.")
                    tabBarController?.selectedIndex = 0
                }
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
        FireBaseService.shared.testConnection { isConnected in
            if !isConnected {
                self.presentAlert(title: "No Connection", message: "Please come back whe you will have \n a good network connection.")
            }
        }
        activityIndicator.isHidden = true
        offerId = UUID().uuidString
        NotificationCenter.default.addObserver(self, selector: #selector(addImageNotificationReceived), name: Notification.Name("addImagePostOffer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived(_:)), name: Notification.Name("deletedImagePostOffer"), object: nil)
        collectionView.register(PhotosListCollectionViewCell.nib(), forCellWithReuseIdentifier: "PhotosListCollectionViewCell")
    }
    // MARK: Actions
    @objc func notificationReceived(_ notification: NSNotification) {
        guard let index = notification.object as? Int else {
            return
        }
        offerImages.remove(at: index)
        collectionView.reloadData()
        if offerImages.isEmpty {
            sendOfferButton.isHidden = true
        }
    }
    @objc func addImageNotificationReceived() {
        if self.isViewLoaded {
            let picker              = OpalImagePickerController()
            presentOpalImagePickerController(picker, animated: true) { assets in
                picker.dismiss(animated: true) {
                    for asset in assets {
                        self.offerImages.append(self.getAssetThumbnail(asset: asset, size: 4000))
                    }
                    self.collectionView.reloadData()
                    if FireBaseService.shared.isConnceted {
                        self.sendOfferButton.isHidden = false
                    }
                }
            } cancel: { }
        }
    }
    @IBAction func sendOfferButtonTapped(_ sender: Any) {
        guard let user = Auth.auth().currentUser?.uid, let name = nameTextField.text, let description = descriptionTextField.text else {
            return
        }
        sendOfferButton.isHidden = true
        activityIndicator.isHidden = false
        var offers: [String: String] = users[user]?.offers ?? [:]
        offers[offerId] = name
        let category = Categories.allCases[categoryPickerView.selectedRow(inComponent: 0)]
        self.sendData(images: self.offerImages) { urlArray in
            if let imagesUrl = urlArray {
                FireBaseService.shared.populateOffer(id: self.offerId, name: name, description: description, images: imagesUrl, owner: user, category: category.rawValue)
                self.usersRef.child("\(user)/offers").setValue(offers)
                self.performSegue(withIdentifier: "postSuccess", sender: nil)
                self.reset()
            }
        }
    }
    
    @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
    }
    // MARK: Methods
    private func sendData(images: [UIImage], callback: @escaping ([String]?) -> Void) {
        var index = 0
        var urlArray: [String] = []
        let dispatchGroup = DispatchGroup()
        for image in images {
            dispatchGroup.enter()
            if let imageData =  image.pngData() {
                StorageService().saveImage(imageData: imageData, offerId: self.offerId, index: index) { [self] success, url in
                    guard let url = url else {
                        presentAlert(title: "Oups", message: "Something went wrong please try again later")
                        callback(nil)
                        return
                    }
                    if success {
                        let string = url.absoluteString
                        urlArray.append(string)
                        
                    } else {
                        presentAlert(title: "Oups", message: "Something went wrong please try again later")
                        callback(nil)
                    }
                    
                    dispatchGroup.leave()
                }
            }
            index += 1
        }
        dispatchGroup.notify(queue: .main) {
            callback(urlArray)
        }
    }
    private func presentAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action  = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func getAssetThumbnail(asset: PHAsset, size: CGFloat) -> UIImage {
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
        
        manager.requestImage(for: asset,
                                targetSize: retinaSquare,
                                contentMode: .aspectFit,
                                options: options,
                                resultHandler: {(result, _) -> Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    private func reset() {
        sendOfferButton.isHidden       = true
        self.nameTextField.text        = ""
        self.offerImages               = []
        self.imagesUrl                 = []
        self.descriptionTextField.text = ""
        collectionView.reloadData()
        activityIndicator.isHidden = true
    }
    
    private func getNewImageId() -> Int {
        let ids = offers.keys
        var id: String = "0"
        for key in ids where key > id {
            id = key
        }
        if id != "0" {
            return Int(id)! + 1
        } else {
            return 0
        }
        
    }
}
extension PostOfferViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Categories.allCases.count - 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let categories = Categories.allCases
        var categoriesToShow: [String] = []
        for category in categories where category != .all {
            categoriesToShow.append(category.rawValue)
        }
        return categoriesToShow[row]
    }
}

extension PostOfferViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return (imagesUrl.count + 1)
        return offerImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosListCollectionViewCell", for: indexPath) as? PhotosListCollectionViewCell else {
            return UICollectionViewCell()
        }
        if offerImages.count > indexPath.row {
            cell.configure(image: offerImages[indexPath.row], imageUrl: nil, index: indexPath.row, offersId: offerId)
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
