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
    
    //MARK: Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables
    let offersRef = Database.database().reference(withPath: "offers")
    let usersRef = Database.database().reference(withPath: "users")
    var filteredOffers: [String:Offer] = [:]
    var users: [String: User] {
        return FireBaseService.users
    }
    var offers: [String: Offer] {
        return FireBaseService.offers
    }
    var isFiltered: Bool = false
    var selectedOfferIndex: String = "0"
    var offersIds: [String] {
        var ids: [String] = []
        if isFiltered {
            for key in filteredOffers.keys {
                ids.append(key)
            }
        } else {
            for key in FireBaseService.offers.keys {
                ids.append(key)
            }
        }
        return ids
    }
    //MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFilterMenu()
        tableView.rowHeight = 400
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "offerDetailsSegue"{
            var reversedOffers: [String: Offer] {
                if isFiltered {
                    return filteredOffers
                }
                return offers
            }
            let recipeVC = segue.destination as? OfferDetailsViewController
            recipeVC?.selectedOffer = reversedOffers[selectedOfferIndex]
            recipeVC?.users = users
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        FireBaseService.getOffers { success in
            if success {
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: Actions
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
            self.filteredOffers = filteredOffers
            if !self.users.isEmpty {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
    
    //MARK: Methods
    private func presentAlert(title: String,message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    fileprivate func setUpFilterMenu() {
        filterButton.showsMenuAsPrimaryAction = true
        var actionArray: [UIAction] = []
        for category in Categories.allCases {
            let action = UIAction(title: category.rawValue, state: .off, handler: filterButtonTapped(_:))
            actionArray.append(action)
        }
        filterButton.menu = UIMenu(children: actionArray)
    }
    
    func getOffers() -> [String: Offer] {
        if isFiltered {
            return filteredOffers
        }
        return offers
    }
}

extension OffersListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getOffers().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCell", for: indexPath) as? OfferTableViewCell else {
            return UITableViewCell()
        }
        let offerId = offersIds[indexPath.row]
        let offersList: [String: Offer]  = getOffers()
        guard let userId = offersList[offerId]?.owner, let ownerLocation = users[userId]?.address, let ownerZipCode = ownerLocation["Postal Code"], let name = offersList[offerId]?.name, let firstImage = offersList[offerId]?.images[0], let imageURL = URL(string: firstImage) else {
            return UITableViewCell()
        }
        cell.configure(name: name, location: "Zipcode: \n" + ownerZipCode, imageUrl: imageURL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedOfferIndex = offersIds[indexPath.row]
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
        self.isFiltered = true
        var filteredOffers: [String: Offer] = [:]
        for offer in FireBaseService.offers.values {
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


