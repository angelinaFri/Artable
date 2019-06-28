//
//  AddEditProductsVC.swift
//  ArtableAdmin
//
//  Created by Angelina on 6/27/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import UIKit

class AddEditProductsVC: UIViewController {

    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var productPriceTxt: UITextField!
    @IBOutlet weak var productDescTxt: UITextView!
    @IBOutlet weak var productImgView: RoundedImageView!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    @IBOutlet weak var addProductBtn: RoundedButton!
    
    var selectedCategory: Category!
    var productToEdit: Product?

    override func viewDidLoad() {
        super.viewDidLoad()
        gestureRecognizerSetup()

    }

    func gestureRecognizerSetup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped))
        tap.numberOfTapsRequired = 1
        productImgView.isUserInteractionEnabled = true
        productImgView.addGestureRecognizer(tap)
    }

    @objc func imgTapped() {
        // Launch the image picker
        launchImgPicker()

    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
    }

}

extension AddEditProductsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let image = info[.originalImage] as? UIImage else { return }
        productImgView.contentMode = .scaleAspectFill
        productImgView.image = image
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
