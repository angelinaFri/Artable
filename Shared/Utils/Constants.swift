//
//  Constants.swift
//  Artable
//
//  Created by Angelina on 6/21/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import Foundation
import UIKit

struct Storyboard {
    static let LoginStoryboard = "LoginStoryboard"
}

struct StoryboardId {
    static let LoginVC = "loginVC"
}

struct AppImages {
    static let GreenCheck = "green_check"
    static let RedCheck = "red_check"
    static let FilledStar = "filled_star"
    static let EmptyStar = "empty_star"
    static let Placeholder = "placeholder"
}

struct AppColors {
    static let Blue = #colorLiteral(red: 0.2914361954, green: 0.3395442367, blue: 0.4364506006, alpha: 1)
    static let Red = #colorLiteral(red: 0.8352941176, green: 0.3921568627, blue: 0.3137254902, alpha: 1)
    static let OffWhite = #colorLiteral(red: 0.9626371264, green: 0.959995091, blue: 0.9751287103, alpha: 1)
}

struct Identifiers {
    static let CategoryCell = "CategoryCell"
    static let ProductCell = "ProductCell"
    static let CartItemCell = "CartItemCell"
}

struct Segues {
    static let ToProducts = "toProductsVC"
    static let ToAddEditCategory = "ToAddEditCategory"
    static let ToEditCategory = "ToEditCategory"
    static let ToAddEditProduct = "ToAddEditProduct"
    static let ToFavorites = "ToFavorites"
}
