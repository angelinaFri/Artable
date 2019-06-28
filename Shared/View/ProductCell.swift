//
//  ProductCell.swift
//  Artable
//
//  Created by Angelina on 6/24/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import UIKit
import Kingfisher

class ProductCell: UITableViewCell {

    @IBOutlet weak var productImg: RoundedImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()


    }

    func configireCell(product: Product) {
        productTitle.text = product.name
        if let url = URL(string: product.imageUrl) {
            productImg.kf.setImage(with: url)
        }

    }

    @IBAction func addToCartClicked(_ sender: Any) {
    }

    @IBAction func favoriteClicked(_ sender: Any) {
    }

}
