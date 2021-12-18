//
//  OfferDetailsViewController.swift
//  FreeCorner
//
//  Created by Simon Dahan on 16/12/2021.
//

import UIKit

class OfferDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(imageUrl: selectedOffer!.images[indexPath.row])
        return cell
    }
    
    var selectedOffer: Offer?
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.offerImage.load(url: URL(string: selectedOffer!.images.first!)!)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
