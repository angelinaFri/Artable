//
//  RoundedViews.swift
//  Artable
//
//  Created by Angelina on 6/21/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton : UIButton {
    // this method is called right as the class is initialized
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5

    }
}

class RoundedShadowView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        layer.shadowColor = AppColors.Blue.cgColor
        layer.shadowOpacity = 0.4
        // how far away it appears
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
    }
}

class RoundedImageView : UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }
}
