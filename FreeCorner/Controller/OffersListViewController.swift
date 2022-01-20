//
//  ViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 07/12/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class OffersListViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var filteredOffers: [String: Offer] = [:]
    var isFiltered: Bool               = false
    var selectedOfferIndex: String     = "0"
    var users: [String: User]  = [:]
    var offers: [String: Offer] = [:]
    var offersIds: [String] {
        var ids: [String] = []
        if isFiltered {
            for key in filteredOffers.keys {
                ids.append(key)
            }
        } else {
            for key in offers.keys {
                ids.append(key)
            }
        }
        return ids
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFilterMenu()
        tableView.rowHeight = 400
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "offerDetailsSegue"{
            var offers: [String: Offer] {
                if isFiltered {
                    return filteredOffers
                }
                return self.offers
            }
            let recipeVC = segue.destination as? OfferDetailsViewController
            recipeVC?.selectedOffer = offers[selectedOfferIndex]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        FireBaseService.shared.getOffers { offers, success in
            if success {
                self.offers = offers
                self.tableView.reloadData()
            }
        }
        FireBaseService.shared.getUsers {users, success in
            if success {
                self.users = users
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Actions
    @IBAction func filterButtonTapped(_ sender: Any) {
        guard let filter = sender as? UIAction else {
            return
        }
        if filter.title == "All"{
            isFiltered = false
            tableView.reloadData()
            return
        }
        self.isFiltered = true
        filteredOffers = Offer.filterItemsByCategory(category: filter.title, offers: offers)
        tableView.reloadData()
    }
    
    @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
    
    // MARK: Methods
    private func presentAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func setUpFilterMenu() {
        filterButton.showsMenuAsPrimaryAction = true
        var actionArray: [UIAction] = []
        for category in Categories.allCases {
            let action = UIAction(title: category.rawValue, state: .off, handler: filterButtonTapped(_:))
            actionArray.append(action)
        }
        filterButton.menu = UIMenu(children: actionArray)
    }
    func getSortedKeys(_ dict: [String: Offer]) -> [String] {
        let keys: [String] = dict.keys.sorted()
        return keys.reversed()
    }
    func getOffersKeys() -> [String] {
        if isFiltered {
            let sortedOffers = filteredOffers.sorted { $0.key < $1.key }
            print(sortedOffers)
            return getSortedKeys(filteredOffers)
        }
        return getSortedKeys(offers)
    }
}

extension OffersListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getOffersKeys().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCell", for: indexPath) as? OfferTableViewCell else {
            return UITableViewCell()
        }
        let offersKeys                   = self.getOffersKeys()
        let offerId                      = offersKeys[indexPath.row]
        guard let userId = self.offers[offerId]?.owner,
                let ownerLocation = FireBaseService.shared.users[userId]?.address,
                let ownerZipCode = ownerLocation["Postal Code"],
                let name = self.offers[offerId]?.name,
                let firstImage = self.offers[offerId]?.images[0],
                let imageURL = URL(string: firstImage) else {
            return UITableViewCell()
        }
        cell.configure(name: name, location: "Zipcode: \n" + ownerZipCode, imageUrl: imageURL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offersKeys          = getOffersKeys()
        self.selectedOfferIndex = offersKeys[indexPath.row]
        textField.resignFirstResponder()
        performSegue(withIdentifier: "offerDetailsSegue", sender: self)
    }
}

extension OffersListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let searchedItem = textField.text else {
            return true
        }
        if searchedItem.isEmpty {
            self.isFiltered = false
            self.tableView.reloadData()
            return true
        }
        self.isFiltered                     = true
        var filteredOffers: [String: Offer] = [:]
        for offer in FireBaseService.shared.offers.values {
            if offer.name.capitalized.contains(searchedItem.capitalized) {
                filteredOffers[offer.key] = offer
            }
        }
        if filteredOffers.isEmpty {
            presentAlert(title: "No offers", message: "Sorry no offers were found.")
            self.isFiltered = false
        }
        self.filteredOffers = filteredOffers
        if !self.users.isEmpty {
            self.tableView.reloadData()
        }
        return true
    }
}

extension OffersListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.tableView) == true {
            return false
        }
        return true
    }
}
