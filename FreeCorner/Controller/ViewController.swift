//
//  ViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 07/12/2021.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let ref = Database.database().reference(withPath: "offers")
    var refObservers: [DatabaseHandle] = []
    var items: [Offer] = []
    var offersCount: UInt = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 400
    }
    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(true)
      refObservers.forEach(ref.removeObserver(withHandle:))
      refObservers = []
    }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(true)
      ref.observe(.value, with: { snapshot in
        let completed = self.ref.observe(.value) { snapshot in
          var newItems: [Offer] = []
            self.offersCount = snapshot.childrenCount
          for child in snapshot.children {
            if
              let snapshot = child as? DataSnapshot,
              let offer = Offer(snapshot: snapshot) {
              newItems.append(offer)
            }
          }
          self.items = newItems
          self.tableView.reloadData()
        }
        self.refObservers.append(completed)
      })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as? OfferTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(name: items[indexPath.row].name, description: items[indexPath.row].desctiption, location: items[indexPath.row].owner, imageUrl: URL(string: items[indexPath.row].images[0])!)
        return cell
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

