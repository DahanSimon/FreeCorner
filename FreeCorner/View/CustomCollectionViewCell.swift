//
//  CustomCollectionViewCell.swift
//  FreeCorner
//
//  Created by Simon Dahan on 16/12/2021.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var offerPicture: UIImageView!
    
    func configure(imageUrl: String){
        if let url = URL(string: imageUrl) {
            self.offerPicture.load(url: url)
        }
    }
}
