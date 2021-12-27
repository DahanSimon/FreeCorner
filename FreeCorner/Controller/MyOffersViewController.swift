//
//  MyOffersViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 24/12/2021.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class MyOffersViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var usersOffers: [String: Offer] = [:]
    var usersOffersIds: [String] = []
    let userId = Auth.auth().currentUser!.uid
    let offerRef = Database.database().reference(withPath: "offers")
    let userRef = Database.database().reference(withPath: "users")
    var refObservers: [DatabaseHandle] = []
    var selectedOffer: Offer?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 70
        userRef.child(userId).child("offers").observe(.childAdded) { snapshot in
            self.usersOffersIds.append(snapshot.key)
            self.tableView.reloadData()
            for id in self.usersOffersIds {
                let ref = self.offerRef.child(id)
                ref.getData { error, snapshot in
                    print(error.debugDescription)
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
}

extension MyOffersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersOffersIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersOfferCell", for: indexPath) as? UsersOfferTableViewCell else {
            return UITableViewCell()
        }
        
        if (usersOffers.count == usersOffersIds.count) && usersOffersIds.count != 0{
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
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateOffer" {
            let destinationVC = segue.destination as? UpdateOfferViewController
            destinationVC?.selectedOffer = selectedOffer
            destinationVC?.usersOffersIds = usersOffersIds
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedOffer = usersOffers[usersOffersIds[indexPath.row]]
        performSegue(withIdentifier: "updateOffer", sender: self)
    }
}
