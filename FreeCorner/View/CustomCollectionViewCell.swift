//
//  CustomCollectionViewCell.swift
//  FreeCorner
//
//  Created by Simon Dahan on 16/12/2021.
//

import UIKit
import Kingfisher
class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var offerPicture: UIImageView!
    let activityIndicator = UIActivityIndicatorView()
    
    func configure(imageUrl: String){
        activityIndicator.frame = self.offerPicture.bounds
        offerPicture.addSubview(activityIndicator)
//        offerPicture.isHidden = true
        if let url = URL(string: imageUrl) {
            offerPicture.kf.indicatorType = .activity
            offerPicture.kf.setImage(with: url, placeholder: nil, options: nil)
        }
    }
}
