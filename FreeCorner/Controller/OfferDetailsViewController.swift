//
//  OfferDetailsViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 16/12/2021.
//

import UIKit
import MapKit
import CoreLocation
import MessageUI
class OfferDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let offer = selectedOffer else {
            return 1
        }
        return offer.images.count
    }
    
    @IBAction func sendEmailButtonTapped(_ sender: Any) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = [users![Int(self.selectedOffer!.owner)! - 1].phone]
        composeVC.body = "Hey! Your product on FreeKorner is still available ? \nThank you !"
        
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    @IBAction func phoneButtonTapped(_ sender: Any) {
        guard let users = users, let selectedOffer = self.selectedOffer, let ownerId = Int(selectedOffer.owner) else {
            return
        }
        let phoneNumber = users[ownerId - 1].phone
        if !phoneNumber.isEmpty {
            if let url = URL(string: "tel://" + phoneNumber) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(imageUrl: selectedOffer!.images[indexPath.row])
        return cell
    }
    
    var selectedOffer: Offer?
    var users: [User]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionLabel.text = selectedOffer?.desctiption
        let address = users?[Int(self.selectedOffer!.owner)! - 1].address["Postal Code"]
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address!) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                return
            }
            
            let region = MKCoordinateRegion( center: location.coordinate, latitudinalMeters: CLLocationDistance(exactly: 5000)!, longitudinalMeters: CLLocationDistance(exactly: 5000)!)
            self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
            let artwork = Artwork(
                title: self.users?[Int(self.selectedOffer!.owner)! - 1].address["City Name"],
                locationName: "",
                discipline: "",
                coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            self.mapView.addAnnotation(artwork)
        }
    }
}


