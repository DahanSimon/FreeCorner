//
//  ViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 07/12/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let offersRef = Database.database().reference(withPath: "offers")
    let usersRef = Database.database().reference(withPath: "users")
    var refObservers: [DatabaseHandle] = []
    var filteredItems: [String:Offer] = [:]
    var users: [String:User] = [:]
    var isFiltered: Bool = false
    var selectedOfferIndex: String = "0"
    var offersIds: [String] {
        var ids: [String] = []
        for key in FireBaseService.offers.keys {
            ids.append(key)
        }
        return ids
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterButton.showsMenuAsPrimaryAction = true
        var actionArray: [UIAction] = []
        for category in Categories.allCases {
            let action = UIAction(title: category.rawValue, state: .off, handler: filterButtonTapped(_:))
            actionArray.append(action)
        }
        filterButton.menu = UIMenu(children: actionArray)
        tableView.rowHeight = 400
    }
    @objc func refresh(_ sender:AnyObject) {
        tableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        refObservers.forEach(offersRef.removeObserver(withHandle:))
        refObservers.forEach(usersRef.removeObserver(withHandle:))
        refObservers = []
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "offerDetailsSegue"{
            var reversedOffers: [String: Offer] {
                if isFiltered {
                    return filteredItems
                }
                return FireBaseService.offers
            }
            let recipeVC = segue.destination as? OfferDetailsViewController
            recipeVC?.selectedOffer = reversedOffers[selectedOfferIndex]
            recipeVC?.users = self.users
        }
    }
    @IBAction func filterButtonTapped(_ sender: Any) {
        guard let filter = sender as? UIAction else {
            return
        }
        self.isFiltered = true
        offersRef.queryOrdered(byChild: "category").queryEqual(toValue: filter.title).observe(.value) { snapshot in
            var filteredOffers: [String: Offer] = [:]
            for child in snapshot.children {
                if
                    let snapshot = child as? DataSnapshot,
                    let offer = Offer(snapshot: snapshot) {
                    filteredOffers[offer.key] = offer
                }
            }
            self.filteredItems = filteredOffers
            if !self.users.isEmpty {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        usersRef.observe(.value, with: { snapshot in
            let completed = self.usersRef.observe(.value) { snapshot in
                var newUsers: [String:User] = [:]
                for child in snapshot.children {
                    if
                        let snapshot = child as? DataSnapshot,
                        let user = User(snapshot: snapshot) {
                        newUsers[user.key] = user
                    }
                }
                self.users = newUsers
                self.tableView.reloadData()
            }
            self.refObservers.append(completed)
        })
        tableView.reloadData()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getOffers().count
    }
    func getOffers() -> [String: Offer] {
        if isFiltered {
            return filteredItems
        }
        return FireBaseService.offers
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCell", for: indexPath) as? OfferTableViewCell else {
            return UITableViewCell()
        }
        let offerId = offersIds[indexPath.row]
        let itemsList: [String: Offer]  = getOffers()
        var ownerLocation: [String: String] = ["Postal Code":""]
        let userIndex = itemsList[offerId]?.owner
        ownerLocation = users[userIndex!]!.address
        cell.configure(name: itemsList[offerId]!.name, location: "Zipcode: \n" + ownerLocation["Postal Code"]!, imageUrl: URL(string: (itemsList[offerId]?.images[0])!)!)
        print(FireBaseService.offers)
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedOfferIndex = offersIds[indexPath.row]
        performSegue(withIdentifier: "offerDetailsSegue", sender: self)
    }
}
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let searchedItem = textField.text else {
            return true
        }
        self.isFiltered = true
        var filteredItems: [String: Offer] = [:]
        for item in FireBaseService.offers.values {
            if item.name.capitalized.contains(searchedItem.capitalized) {
                filteredItems[item.key] = item
            }
        }
        if filteredItems.isEmpty {
            presentAlert(title: "No offers", message: "Sorry no offers were found.")
            self.isFiltered = false
        }
        self.filteredItems = filteredItems
        if !self.users.isEmpty {
            self.tableView.reloadData()
        }
        return true
    }
    
    private func presentAlert(title: String,message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
}


