//
//  ProductDetailVC.swift
//  Artable
//
//  Created by Angelina on 6/26/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import UIKit
import Kingfisher

class ProductDetailVC: UIViewController {

    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var bgView: UIVisualEffectView!

    var product: Product!

    override func viewDidLoad() {
        super.viewDidLoad()

        productTitle.text = product.name
        productDescription.text = product.productDescription

        if let url = URL(string: product.imageUrl) {
            productImg.kf.setImage(with: url)
        }

        // convirting price Double to String
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let price = formatter.string(from: product.price as NSNumber) {
            productPrice.text = price
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissProduct(_:)))
        tap.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tap)

    }

    @objc func dismissProduct(_ tap: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addCartClicked(_ sender: Any) {
        StripeCart.addItemToCart(item: product)
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func keepShoppingBtnClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
