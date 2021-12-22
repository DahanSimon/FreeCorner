//
//  OfferTableViewCell.swift
//  FreeCorner
//
//  Created by Simon Dahan on 08/12/2021.
//

import UIKit
import Kingfisher

class ListCustomView: UIView {
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        self.layer.shadowRadius = 2.0
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowOpacity = 2.0
        
    }
}

class OfferTableViewCell: UITableViewCell {

    @IBOutlet weak var offerListView: UIView!
    @IBOutlet weak var offerPicture: UIImageView!
    @IBOutlet weak var offerDescription: UILabel!
    @IBOutlet weak var offerName: UILabel!
    @IBOutlet weak var offerLocation: UILabel!
    let activityIndicator = UIActivityIndicatorView()

    override func awakeFromNib() {
        super.awakeFromNib()
//        offerPicture.isHidden = true
        self.offerListView.layer.cornerRadius = 10
        self.textLabel?.textAlignment = .center
        self.textLabel?.font = UIFont(name: "Montserrat", size: 18)
        addShadow()
    }
    private func addShadow() {
        offerListView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        offerListView.layer.shadowRadius = 2.0
        offerListView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        offerListView.layer.shadowOpacity = 2.0
    }
    func configure(name: String, description: String, location: String, imageUrl: URL) {
        offerDescription.text = description
        offerLocation.text = location
        offerName.text = name
        activityIndicator.frame = self.offerPicture.bounds
        offerPicture.addSubview(activityIndicator)
//        offerPicture.load(url: imageUrl, activyIndicator: activityIndicator, parentView: offerPicture)
        offerPicture.kf.indicatorType = .activity
        offerPicture.kf.setImage(with: imageUrl, placeholder: nil, options: nil)
    }
}
