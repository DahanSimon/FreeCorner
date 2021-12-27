//
//  UpdateOfferViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 25/12/2021.
//

import UIKit
import SwiftUI
import FirebaseDatabase
import FirebaseAuth
class UpdateOfferViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var selectedOffer: Offer?
    var usersOffersIds: [String]?
    let offerRef = Database.database().reference(withPath: "offers")
    let userRef = Database.database().reference(withPath: "users")
    let userId = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(PhotosListCollectionViewCell.nib(), forCellWithReuseIdentifier: "PhotosListCollectionViewCell")
    }
    
    static func deleteImage(cell: PhotosListCollectionViewCell) {
        
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
        if selectedOffer.images.count > indexPath.row{
            cell.configure(imageUrl:selectedOffer.images[indexPath.row],index: indexPath.row, offersId: selectedOffer.key)
        } else {
            cell.showAddImageButton()
        }
        
        return cell
    }
}
