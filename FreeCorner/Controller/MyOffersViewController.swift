//
//  MyOffersViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 24/12/2021.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class MyOffersViewController: UIViewController, UpdateOfferDelegate {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var usersOffers: [String: Offer]    = [:]
    var usersOffersIds: [String]        = []
    let userId                          = Auth.auth().currentUser!.uid
    let offerRef                        = Database.database().reference(withPath: "offers")
    let userRef                         = Database.database().reference(withPath: "users")
    var refObservers: [DatabaseHandle]  = []
    var selectedOffer: Offer?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        FireBaseService.shared.testConnection { isConnected in
            if !isConnected {
                self.presentAlert(title: "No Connection", message: "Please come back whe you will have \n a good network connection.")
            }
        }
        self.tableView.rowHeight = 70
        
        offerRef.observe(.childChanged) { _ in
            self.tableView.reloadData()
        }
        userRef.child(userId).child("offers").observe(.childAdded) { snapshot in
            self.usersOffersIds.append(snapshot.key)
            self.tableView.reloadData()
            for id in self.usersOffersIds {
                let ref = self.offerRef.child(id)
                ref.getData { _, snapshot in
                    var newItems: [String: Offer] = [:]
                    for child in snapshot.children {
                        if
                            let snapshot = child as? DataSnapshot,
                            let offer = Offer(snapshot: snapshot) {
                            newItems[offer.key] = offer
                        }
                    }
                    self.usersOffers[id] = newItems[id]
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateOffer" {
            let destinationVC = segue.destination as? UpdateOfferViewController
            destinationVC?.selectedOfferIndex = selectedOffer?.key
            destinationVC?.usersOffersIds = usersOffersIds
            destinationVC?.updateOfferDelegate = self
        }
    }
    
    // MARK: Methods
    func didUpdateOffer(name: String, id: String, description: String, images: [String], owner: String, category: String) {
        FireBaseService.shared.populateOffer(id: id, name: name, description: description, images: images, owner: owner, category: category)
        usersOffers[String(id)] = Offer(name: name, description: description, images: images, owner: owner, category: category, key: String(id))
        tableView.reloadData()
    }
    
    private func presentAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    deinit {
        print("my offers deinited")
    }
}

extension MyOffersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersOffersIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersOfferCell", for: indexPath) as? UsersOfferTableViewCell else {
            return UITableViewCell()
        }
        
        if (usersOffers.count == usersOffersIds.count) && usersOffersIds.count != 0 {
            let offersId = usersOffersIds[indexPath.row]
            cell.textLabel!.text = usersOffers[String(offersId)]?.name
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if usersOffersIds.count != 0 {
            if editingStyle == .delete {
                let offersId = usersOffersIds[indexPath.row]
                self.usersOffers.removeValue(forKey: offersId)
                self.usersOffersIds.remove(at: indexPath.row)
                offerRef.child(offersId).removeValue()
                userRef.child(userId).child("offers").child(offersId).removeValue()
                StorageService().deleteImages(offerId: offersId)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedOffer = usersOffers[usersOffersIds[indexPath.row]]
        performSegue(withIdentifier: "updateOffer", sender: self)
    }
}
