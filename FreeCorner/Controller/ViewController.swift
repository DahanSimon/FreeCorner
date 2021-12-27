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
    var items: [Offer] = []
    var filteredItems: [Offer] = []
    var users: [String:User] = [:]
    var isFiltered: Bool = false
    var selectedOfferIndex: Int = 0
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
            var reversedOffers: [Offer] {
                if isFiltered {
                    return filteredItems.reversed()
                }
                return items.reversed()
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
            var filteredOffers: [Offer] = []
            for child in snapshot.children {
                if
                    let snapshot = child as? DataSnapshot,
                    let offer = Offer(snapshot: snapshot) {
                    filteredOffers.append(offer)
                }
            }
            self.filteredItems = filteredOffers
            if !self.users.isEmpty {
                self.tableView.reloadData()
            }
        }
    }
    @IBAction func logOut(_ sender: UIButton) {
        try? Auth.auth().signOut()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        offersRef.observe(.value, with: { snapshot in
            let completed = self.offersRef.observe(.value) { snapshot in
                var newItems: [Offer] = []
                for child in snapshot.children {
                    if
                        let snapshot = child as? DataSnapshot,
                        let offer = Offer(snapshot: snapshot) {
                        newItems.append(offer)
                    }
                }
                self.items = newItems
            }
            self.refObservers.append(completed)
        })
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
    func getOffers() -> [Offer] {
        if isFiltered {
            return filteredItems.reversed()
        }
        return FireBaseService.offers.reversed()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCell", for: indexPath) as? OfferTableViewCell else {
            return UITableViewCell()
        }
        let itemsList: [Offer]  = getOffers()
        var ownerLocation: [String: String] = ["Postal Code":""]
        let userIndex = itemsList[indexPath.row].owner
        ownerLocation = users[userIndex]!.address
        cell.configure(name: itemsList[indexPath.row].name, description: itemsList[indexPath.row].desctiption, location: "Zipcode: \n" + ownerLocation["Postal Code"]!, imageUrl: URL(string: itemsList[indexPath.row].images[0])!)
        print(FireBaseService.offers)
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedOfferIndex = indexPath.row
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
        var filteredItems: [Offer] = []
        for item in items {
            if item.name.capitalized.contains(searchedItem.capitalized) {
                filteredItems.append(item)
            }
        }
        if filteredItems.isEmpty {
            presentAlert(message: "Sorry no offers were found.")
            self.isFiltered = false
        }
        self.filteredItems = filteredItems
        if !self.users.isEmpty {
            self.tableView.reloadData()
        }
        return true
    }
    
    private func presentAlert(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
}


