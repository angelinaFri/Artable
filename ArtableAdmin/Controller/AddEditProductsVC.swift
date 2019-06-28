//
//  AddEditProductsVC.swift
//  ArtableAdmin
//
//  Created by Angelina on 6/27/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AddEditProductsVC: UIViewController {

    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var productPriceTxt: UITextField!
    @IBOutlet weak var productDescTxt: UITextView!
    @IBOutlet weak var productImgView: RoundedImageView!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    @IBOutlet weak var addProductBtn: RoundedButton!
    
    var selectedCategory: Category!
    var productToEdit: Product?

    var name = ""
    var price = 0.0
    var productDescription = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        gestureRecognizerSetup()
        passingProductDataForEditing()


    }

    func passingProductDataForEditing() {
        //Information to be passed to VC for editing
        if let product = productToEdit {
            productNameTxt.text = product.name
            productDescTxt.text = product.productDescription
            productPriceTxt.text = String(product.price)
            addProductBtn.setTitle("Save changes", for: .normal)

            if let url = URL(string: product.imageUrl) {
                productImgView.contentMode = .scaleAspectFill
                productImgView.kf.setImage(with: url)
            }
        }
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
        uploadImageThenDocument()
    }

    func uploadImageThenDocument() {
        guard let image = productImgView.image,
        let name = productNameTxt.text, name.isNotEmpty,
        let description = productDescTxt.text, description.isNotEmpty,
        let priceString = productPriceTxt.text,
            let price = Double(priceString) else {
                simpleAlert(title: "Missing Fields", msg: "Please, fill out all required fields.")
                return
        }

        self.name = name
        self.productDescription = description
        self.price = price

        activityindicator.startAnimating()

        // Step 1: Turn the image into Data
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }

        // Step 2: Create an storage image reference -> A location in Firestore for it to be stored.
        let imageRef = Storage.storage().reference().child("/productImages/\(name).jpg") //path

        // Step 3: Set the meta data
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"

        // Step 4: Upload the data
        imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if let error = error {
                self.handleError(error: error, msg: "Unable to upload image.")
                return
            }

            // Step 5: Once the image is uploaded, retrieve the download URL
            imageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    self.handleError(error: error, msg: "Unable to download url")
                    return
                }
                guard let url = url else { return }
                print(url)
                // Step 6: Upload new Product document to the Firestore products collection
                self.uploadDocument(url: url.absoluteString)
            })

        }

    }

    func uploadDocument(url: String) {
        // we need a document reference to upload a new product document to Firestore
        // products collections
        var docRef: DocumentReference!
        var product = Product.init(name: name, id: "", category: selectedCategory.id, price: price, productDescription: productDescription, imageUrl: url)
        
        //checking if we're editing ot adding a new one
        if let productToEdit = productToEdit {
            //We are editing a product
            docRef = Firestore.firestore().collection("products").document(productToEdit.id)
            product.id = productToEdit.id
        } else {
            //We are adding a new product
            docRef = Firestore.firestore().collection("products").document()
            product.id = docRef.documentID
        }

        let data = Product.modelToData(product: product)
        docRef.setData(data, merge: true) { (error) in

            if let error = error {
                self.handleError(error: error, msg: "Unable to upload Firestore document.")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    func handleError(error: Error, msg: String) {
        debugPrint(error.localizedDescription)
        simpleAlert(title: "Error", msg: msg)
        activityindicator.stopAnimating()
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
