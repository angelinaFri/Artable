//
//  CartItemCell.swift
//  Artable
//
//  Created by Angelina on 7/1/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import UIKit

class CartItemCell: UITableViewCell {

    @IBOutlet weak var productImg: RoundedImageView!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var removeItemBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeItemClicked(_ sender: Any) {
    }
}
