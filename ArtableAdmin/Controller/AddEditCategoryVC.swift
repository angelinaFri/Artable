//
//  AddEditCategoryVC.swift
//  ArtableAdmin
//
//  Created by Angelina on 6/27/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AddEditCategoryVC: UIViewController {

    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var categoryImg: RoundedImageView!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    @IBOutlet weak var addBtn: UIButton!

    var categoryToEdit: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapSetup()
        editingCategorySetup()

    }

    func editingCategorySetup() {
        // If we're editing, categoryToEdit will != nil
        if let category = categoryToEdit {
            nameTxt.text = category.name
            addBtn.setTitle("Save Changes", for: .normal)
            
            if let url = URL(string: category.imgUrl) {
                categoryImg.contentMode = .scaleToFill
                categoryImg.kf.setImage(with: url)
            }
        }
    }

    func tapSetup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        categoryImg.isUserInteractionEnabled = true //available in StoryBoard too
        categoryImg.addGestureRecognizer(tap)
    }

    @objc func imgTapped(_ tap: UITapGestureRecognizer) {
        launchImgPicker()
    }
    
    @IBAction func addCategoryClicked(_ sender: Any) {
        uploadImageThenDocument()
    }

    //uploading the image that has been selected from image picker
    func uploadImageThenDocument() {
        guard let image = categoryImg.image,
            let categoryName = nameTxt.text, categoryName.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Must add category image and name")
                return
        }
        activityindicator.startAnimating()

        // Step 1: Turn the image into Data.
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        // range 0...1, where 1 is fully compressed

        // Step 2: Create an storage image reference -> A location in
        //         Firestore for it to be stored.
        let imageRef = Storage.storage().reference().child("/categoryImages/\(categoryName).jpg")

        // Step 3: Set the meta data -> So Firestore knows what kind of file it is
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        // Step 4: Upload the data.
        imageRef.putData(imageData, metadata: metaData) { (metaData, error) in

            if let error = error {
                self.handleError(error: error, msg: "Unable to upload image.")
                return
            }

            // Step 5: Once the image is uploaded, retrieve the download URL.
            imageRef.downloadURL(completion: { (url, error) in
                // url = dowload url from FireStorage
                if let error = error {
                    self.handleError(error: error, msg: "Unable to retrieve image url.")
                    return
                }

                guard let url = url else { return }

                // Step 6: Upload new Category document to the Firestore categories collection.
                self.uploadDocument(url: url.absoluteString)
            })
        }
    }

    func uploadDocument(url: String) {
        var docRef: DocumentReference!
        var category = Category.init(name: nameTxt.text!, //we already check it earlier
                                     id: "",
                                     imgUrl: url, // from func parameter
                                     timeStamp: Timestamp())
                                    // we already set isActive to `true`
        if let categoryToEdit = categoryToEdit {
            // We are editing and updating the existing category
            docRef = Firestore.firestore().collection("categories").document(categoryToEdit.id)
            category.id = categoryToEdit.id
        } else {
            // Creating new category
            docRef = Firestore.firestore().collection("categories").document()
            category.id = docRef.documentID
        }


        //editing category or adding a brand new one
        let data = Category.modelToData(category: category)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                self.handleError(error: error, msg: "Unable to upload new category to Firestore")
                return
            }
            //will back us to categories view
            self.navigationController?.popViewController(animated: true)
        }

    }

    func handleError(error: Error, msg: String) {
        debugPrint(error.localizedDescription)
        self.simpleAlert(title: "Error", msg: msg)
        self.activityindicator.stopAnimating()
    }

}

extension AddEditCategoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func launchImgPicker() {

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // image that we selected
        guard let image = info[.originalImage] as? UIImage else { return }
        // content mode changed because we have `center` in StoryBoard
        categoryImg.contentMode = .scaleAspectFill
        categoryImg.image = image
        dismiss(animated: true, completion: nil)
    }

    //if we cancel w/o selecting any image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }



}
