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
class OfferDetailsViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Variables
    var selectedOffer: Offer?
    var users: [String: User] {
        return FireBaseService.shared.users
    }
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionLabel.text = selectedOffer?.desctiption
        setUpMap()
    }
    // MARK: Actions
    @IBAction func sendMessageButtonTapped(_ sender: Any) {
        guard let selectedOffer = selectedOffer, let owner = users[selectedOffer.owner] else {
            return
        }

        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = [owner.phone]
        composeVC.body       = "Hey! Your product on FreeCorner is still available ? \nThank you !"
        
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    @IBAction func phoneButtonTapped(_ sender: Any) {
        guard let selectedOffer = self.selectedOffer else {
            return
        }
        let phoneNumber = users[selectedOffer.owner]!.phone
        if !phoneNumber.isEmpty {
            if let url = URL(string: "tel://" + phoneNumber) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    deinit {
        print("offer details deinited")
    }
    
    private func setUpMap() {
        guard let selectedOffer = self.selectedOffer, let owner = users[selectedOffer.owner], let postalCode = owner.address["Postal Code"], let cityName = owner.address["City Name"] else {
            return
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(postalCode) { (placemarks, _ ) in
            guard
                let placemarks = placemarks,
                let location   = placemarks.first?.location
            else {
                return
            }
            
            let region = MKCoordinateRegion( center: location.coordinate, latitudinalMeters: CLLocationDistance(exactly: 5000)!, longitudinalMeters: CLLocationDistance(exactly: 5000)!)
            self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
            let artwork = Artwork(
                title: cityName,
                locationName: "",
                discipline: "",
                coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            self.mapView.addAnnotation(artwork)
        }
    }
}

extension OfferDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let offer = selectedOffer else {
            return 1
        }
        return offer.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(imageUrl: selectedOffer!.images[indexPath.row])
        return cell
    }
}

extension OfferDetailsViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
