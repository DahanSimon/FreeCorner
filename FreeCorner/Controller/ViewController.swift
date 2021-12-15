//
//  ViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 07/12/2021.
//

import UIKit
import FirebaseDatabase
class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let offersRef = Database.database().reference(withPath: "offers")
    let usersRef = Database.database().reference(withPath: "users")
    var refObservers: [DatabaseHandle] = []
    var items: [Offer] = []
    var filteredItems: [Offer] = []
    var users: [User] = []
    var isFiltered: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        filterButton.showsMenuAsPrimaryAction = true
        filterButton.menu = UIMenu(children: [
            UIAction(title: "smartphone", state: .off, handler: filterButtonTapped(_:)),
            UIAction(title: "furniture",  state: .off, handler: filterButtonTapped(_:)),
            UIAction(title: "other", state: .off, handler: filterButtonTapped(_:))
        ])
        tableView.rowHeight = 400
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        refObservers.forEach(offersRef.removeObserver(withHandle:))
        refObservers.forEach(usersRef.removeObserver(withHandle:))
        refObservers = []
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
                if !self.users.isEmpty {
                    self.tableView.reloadData()
                }
            }
            self.refObservers.append(completed)
        })
        usersRef.observe(.value, with: { snapshot in
            let completed = self.usersRef.observe(.value) { snapshot in
                
                var newUsers: [User] = []
                for child in snapshot.children {
                    if
                        let snapshot = child as? DataSnapshot,
                        let user = User(snapshot: snapshot) {
                        newUsers.append(user)
                    }
                }
                self.users = newUsers
                self.tableView.reloadData()
            }
            self.refObservers.append(completed)
        })
        tableView.reloadData()
    }
    
    func toAnyObject(offer: Offer) -> [[String: Any]] {
        var result: [[String: Any]] = [[:]]
        var interResult: [String: Any] = [:]
        interResult["name"] = offer.name
        interResult["description"] = offer.desctiption
        interResult["owner"] = offer.owner
        result.append(interResult)
        return result
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered {
            return filteredItems.count
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as? OfferTableViewCell else {
            return UITableViewCell()
        }
        var itemsList: [Offer] {
            if isFiltered {
                return filteredItems
            }
            return items
        }
        let reversedItems: [Offer] = itemsList.reversed()
        var ownerLocation: [String: String] = ["Postal Code":""]
        if let userIndex = Int(reversedItems[indexPath.row].owner) {
            ownerLocation = users[userIndex].address
        }
        cell.configure(name: reversedItems[indexPath.row].name, description: reversedItems[indexPath.row].desctiption, location: "Zipcode: \n" + ownerLocation["Postal Code"]!, imageUrl: URL(string: reversedItems[indexPath.row].images[0])!)
        return cell
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let searchedItem = textField.text else {
            return true
        }
        self.isFiltered = true
        offersRef.queryOrdered(byChild: "name").queryEqual(toValue: searchedItem).observe(.value) { snapshot in
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
        print(searchedItem)
        return true
    }
    
    
    @IBAction func hideKeyboard(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
}

extension UIImageView {
    
    // This method download an image from an URL
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

