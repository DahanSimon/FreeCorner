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

class PostOfferViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate {
    //    let user = Auth.auth().currentUser
    var offers: [String: Offer] = [:]
    var usersOffers: [String: String]? = [:]
    let offersRef = Database.database().reference(withPath: "offers")
    let usersRef = Database.database().reference(withPath: "users")
    var refObservers: [DatabaseHandle] = []
    var offerName: String?
    var offerDescription: String?
    var offerImages: [UIImage] = []
    var imagesUrl: [String] = []
    var owner = "1"
    var category: Category?
    let storage = Storage.storage().reference()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sendOfferButton: UIButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var photoListLabel: UITextView!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    @IBAction func uploadImage(_ sender: Any) {
        imagesUrl = []
        offerImages = []
        photoListLabel.text = ""
        let picker = OpalImagePickerController()
        var images: [UIImage] = []
        presentOpalImagePickerController(picker, animated: true) { assets in
            picker.dismiss(animated: true) {
                for asset in assets {
                    images.append(self.getAssetThumbnail(asset: asset, size: 400))
                }
                self.offerImages = images
                print(images)
                for i in 0..<self.offerImages.count {
                    self.sendData(image: self.offerImages[i], index: i)
                }
                
                self.sendOfferButton.isHidden = true
            }
            
        } cancel: {
            print("cancel")
        }
        
    }
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
                self.photoListLabel.isHidden = false
                self.photoListLabel.text = self.photoListLabel.text! + "\n image\(index).png"
                self.sendOfferButton.isHidden = false
            }
        }
        
    }
    func getAssetThumbnail(asset: PHAsset, size: CGFloat) -> UIImage {
        let retinaScale = UIScreen.main.scale
        let retinaSquare = CGSize(width: size * retinaScale, height: size * retinaScale)
        let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
        let square = CGRect(x: 0, y: 0, width: CGFloat(cropSizeLength), height: CGFloat(cropSizeLength))
        let cropRect = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(asset.pixelWidth), y: 1.0/CGFloat(asset.pixelHeight)))
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var thumbnail = UIImage()
        
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
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
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "signUpSegue", sender: self)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //        try? Auth.auth().signOut()
        offersRef.observe(.value, with: { snapshot in
            let completed = self.offersRef.observe(.value) { snapshot in
                var newItems: [String: Offer] = [:]
                for child in snapshot.children {
                    if
                        let snapshot = child as? DataSnapshot,
                        let offer = Offer(snapshot: snapshot) {
                        newItems[offer.key] = offer
                        if offer.owner == Auth.auth().currentUser?.uid {
                            self.usersOffers?[offer.key] = offer.name
                            self.usersRef.child("\(Auth.auth().currentUser!.uid)/offers").setValue(self.usersOffers)
                        }
                    }
                }
                self.offers = newItems
            }
            self.refObservers.append(completed)
        })
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        sendOfferButton.isHidden = true
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        guard let imageData = image.pngData() else {
            return
        }
        storage.child("images/\(self.offers.count)/image\(self.offerImages.count).png").putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                print("error")
                return
            }
            self.storage.child("images/\(self.offers.count)/image\(self.offerImages.count).png").downloadURL { url, error in
                guard let url = url, error == nil else {
                    print("error")
                    return
                }
                let string = url.absoluteString
                self.imagesUrl.append(string)
                self.photoListLabel.isHidden = false
                self.photoListLabel.text = self.photoListLabel.text! + "\n image\(self.offerImages.count).png"
                self.sendOfferButton.isHidden = false
            }
        }
    }
    @IBAction func sendOfferButtonTapped(_ sender: Any) {
        //        let user = Auth.auth().currentUser
        guard let user = Auth.auth().currentUser?.uid, let name = nameTextField.text, let description = descriptionTextField.text else {
            return
        }
        let category = Categories.allCases[categoryPickerView.selectedRow(inComponent: 0)]
        let ids = offers.keys
        var id: String {
            var id1: String = "0"
            for key in ids {
                if key > id1 {
                    id1 = key
                }
            }
            return id1
        }
        FireBaseService().populateOffer(id: Int(id)! + 1, name: name, description: description, images: imagesUrl, owner: user, category: category.rawValue)
        
        reset()
    }
    func reset() {
        sendOfferButton.isHidden = true
        self.nameTextField.text = ""
        self.offerImages = []
        self.photoListLabel.text = ""
        self.descriptionTextField.text = ""
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendOfferButton.isHidden = true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        return Categories.allCases[row].rawValue
    }
}
