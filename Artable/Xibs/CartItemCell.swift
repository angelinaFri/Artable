//
//  CartItemCell.swift
//  Artable
//
//  Created by Angelina on 7/1/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import UIKit
import Kingfisher

protocol CartItemDelegate: class {
    func removeItem(product: Product)
}

class CartItemCell: UITableViewCell {

    @IBOutlet weak var productImg: RoundedImageView!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var removeItemBtn: UIButton!

    private var item: Product!
    weak var delegate: CartItemDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(product: Product, delegate: CartItemDelegate) {
        self.delegate = delegate
        self.item = product

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        if let price = formatter.string(from: product.price as NSNumber) {
            productTitleLbl.text = "\(product.name) \(price)"
        }

        if let url = URL(string: product.imageUrl) {
            productImg.kf.setImage(with: url)
        }
    }
    
    @IBAction func removeItemClicked(_ sender: Any) {
        delegate?.removeItem(product: item)
    }
}
