//
//  ProductCell.swift
//  Artable
//
//  Created by Angelina on 6/24/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import UIKit
import Kingfisher

protocol ProductCellDelegate: class {
    func productFavorited(product: Product)
    func productAddToCart(product: Product)
}

class ProductCell: UITableViewCell {

    @IBOutlet weak var productImg: RoundedImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!

    weak var delegate: ProductCellDelegate?
    private var product: Product!

    override func awakeFromNib() {
        super.awakeFromNib()


    }

    func configireCell(product: Product, delegate: ProductCellDelegate) {
        self.product = product
        self.delegate = delegate
        productTitle.text = product.name
        if let url = URL(string: product.imageUrl) {
            //short way
            //      productImg.kf.setImage(with: url)
            let placeholderImg = UIImage(named: AppImages.Placeholder)
            productImg.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            productImg.kf.setImage(with: url, placeholder: placeholderImg, options: options)
            
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let price = formatter.string(from: product.price as NSNumber) {
            productPrice.text = price
        }
        //check if this product is favorite
        if UserService.favorites.contains(product) {
            favoriteBtn.setImage(UIImage(named: AppImages.FilledStar), for: .normal)
        } else {
            favoriteBtn.setImage(UIImage(named: AppImages.EmptyStar), for: .normal)
        }

    }





    @IBAction func addToCartClicked(_ sender: Any) {
        delegate?.productAddToCart(product: product)
    }

    @IBAction func favoriteClicked(_ sender: Any) {
        delegate?.productFavorited(product: product)
    }

}
