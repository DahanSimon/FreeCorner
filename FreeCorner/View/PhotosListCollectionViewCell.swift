//
//  PhotosListCollectionViewCell.swift
//  FreeCorner
//
//  Created by Simon Dahan on 26/12/2021.
//

import UIKit
class PhotosListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var offerPicture: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var addImageButton: UIButton!
    let activityIndicator = UIActivityIndicatorView()
    var index: Int = 0
    var offersId: String = ""
    
    func configure(imageUrl: String, index: Int, offersId: String){
        self.index = index
        self.offersId = offersId
        addImageButton.isHidden = true
        offerPicture.isHidden = false
        button.isHidden = false
        activityIndicator.frame = self.offerPicture.bounds
        offerPicture.addSubview(activityIndicator)
//        offerPicture.isHidden = true
        if let url = URL(string: imageUrl) {
            offerPicture.kf.indicatorType = .activity
            offerPicture.kf.setImage(with: url, placeholder: nil, options: nil)
        }
        
    }
    func showAddImageButton() {
        addImageButton.isHidden = false
        offerPicture.isHidden = true
        button.isHidden = true
    }
    @IBAction func deleteButtonTapped(_ sender: Any) {
        FireBaseService().deleteImage(offersId: offersId, imageId: String(index))
    }
    static func nib() -> UINib {
        return UINib(nibName: "PhotosListCollectionViewCell", bundle: nil)
    }
}
