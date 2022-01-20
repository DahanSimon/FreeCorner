//
//  UsersOfferTableViewCell.swift
//  FreeCorner
//
//  Created by Simon Dahan on 24/12/2021.
//

import UIKit

class UsersOfferTableViewCell: UITableViewCell {
    
    @IBOutlet weak var customView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel?.textAlignment = .center
        self.textLabel?.font = UIFont(name: "Montserrat", size: 18)
        self.textLabel?.adjustsFontSizeToFitWidth = true
        self.textLabel?.textColor = .white
        self.customView.layer.cornerRadius = 10
//        addShadow()
    }
    private func addShadow() {
        customView.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        customView.layer.shadowRadius = 2.0
        customView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        customView.layer.shadowOpacity = 2.0
    }
}
