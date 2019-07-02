//
//  ViewController.swift
//  Artable
//
//  Created by Angelina on 6/18/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import UIKit
import Firebase

class HomeVC: UIViewController {

    @IBOutlet weak var loginOutBtn: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var categories = [Category]()
    var selectedCategory: Category!
    var db: Firestore!
    var listener: ListenerRegistration! // for removing when we no longer need it

    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupCollectionView()
        setupInitialAnonymousUser()
        setupNavigationBar()
    }

    func setupNavigationBar() {
        guard let font = UIFont(name: "futura", size: 26) else { return }
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font]

    }

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        //register the nib (collectionview cell xib)
        collectionView.register(UINib(nibName: Identifiers.CategoryCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.CategoryCell)
    }

    func setupInitialAnonymousUser() {
        //the very first time the user opens an app // sign in anonymously
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (result, error) in
                if let error = error {
                    Auth.auth().handleFireAuthError(error: error, vc: self)
                    debugPrint(error)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        // fetchDocument()
        //fetchCollection()
        setCategoriesListener()
        if let user = Auth.auth().currentUser, !user.isAnonymous { // is NOT anonymous
            // we are logged in
            loginOutBtn.title = "Logout"
            //check if our UserListener is currently active for avoiding dupclicates
            //or to start it
            if UserService.userListener == nil {
                UserService.getCurrentUser()
            }

        } else {
            loginOutBtn.title = "Login"
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        listener.remove()
        categories.removeAll()
        collectionView.reloadData()

    }

    func setCategoriesListener() {
        listener = db.categories.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }

            snap?.documentChanges.forEach({ (change) in
                // 3 func to handle each change case

                let data = change.document.data()
                let category = Category.init(data: data)

                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, category: category)
                case .modified:
                    self.onDocumentModified(change: change, category: category)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
        })
    }


    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }

    @IBAction func favoritesClicked(_ sender: Any) {
        performSegue(withIdentifier: Segues.ToFavorites, sender: self)
    }


    @IBAction func loginOutClicked(_ sender: Any) {

        // The user story after `else` is: the User was logged in as registered one (with email).
        // When User press Logout the new anonymous state is activated

        guard let user = Auth.auth().currentUser else { return }
        if user.isAnonymous {
            presentLoginController()
        } else {
            do {
                try Auth.auth().signOut()
                UserService.logoutUser()
                Auth.auth().signInAnonymously { (result, error) in
                    if let error = error {
                        debugPrint(error)
                        Auth.auth().handleFireAuthError(error: error, vc: self)
                    }
                    self.presentLoginController()
                }
            } catch {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                debugPrint(error)
            }
        }
        // Verification we are logged in
        /* if let _ = Auth.auth().currentUser {
            do {
                try Auth.auth().signOut()
                presentLoginController()
            } catch {
                debugPrint(error.localizedDescription)
            }
        } else {
            presentLoginController() // if we're not logged in
        } */
    }
    
}

extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func onDocumentAdded(change: DocumentChange, category: Category) {
        // where in the collection view we should place these categories
        // we do that by accessing the changes' index properties
        let newIndex = Int(change.newIndex)
        categories.insert(category, at: newIndex)
        collectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
    }

    func onDocumentModified(change: DocumentChange, category: Category) {
        //Item changed, but remained in the same position
        // we need to replace the item in categories array with the new item
        // and reload the collection view at that location
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            categories[index] = category // replacing
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])

            //Item changed and changed position
            // we kind of swap the location of old- and newIndex
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            categories.remove(at: oldIndex)
            categories.insert(category, at: newIndex)
            collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }

    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        categories.remove(at: oldIndex)
        collectionView.deleteItems(at: [IndexPath(item: oldIndex, section: 0)])
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.CategoryCell, for: indexPath) as? CategoryCell {
            cell.configureCell(category: categories[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = view.frame.width
        let cellWidth = (width - 30) / 2 // 50 = distance from left & right + distance b/ cells
        let cellHeight = cellWidth * 1.5 // aspect ratio 1.5

        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item]
        performSegue(withIdentifier: Segues.ToProducts, sender: self)
    }

    // passing selectedCategory to ProductsVC

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ToProducts {
            if let destination = segue.destination as? ProductsVC {
                destination.category = selectedCategory
            }
        } else if segue.identifier == Segues.ToFavorites {
            if let destination = segue.destination as? ProductsVC {
                destination.category = selectedCategory
                destination.showFavorites = true
            }
        }
    }
}


// This is prior code, left for reference

//we need a reference before fetching the document from Firestore

/*  func  fetchDocument() {
 let docRef = db.collection("categories").document("nu4lApjKwKTeY6iS8mHa")

 //every time document will be chanched this func will run again

 docRef.addSnapshotListener { (snap, error) in
 // without removeAll() we will have `duplicates` every time the change occurs
 self.categories.removeAll()
 guard let data = snap?.data() else { return }
 let newCategory = Category.init(data: data)
 self.categories.append(newCategory)
 self.collectionView.reloadData()
 }

 // .getDocument fetched data only once

 docRef.getDocument { (snap, error) in
 guard let data = snap?.data() else { return }

 //new instance of the Category struct
 let newCategory = Category.init(data: data)
 self.categories.append(newCategory)
 self.collectionView.reloadData()
 }
 } */


/* func fetchCollection() {
 let collectionReference = db.collection("categories")
 // Listener is active until VC is active. So when user is in another app it
 // will still listen to changes. So we need to remove it
 listener = collectionReference.addSnapshotListener { (snap, error) in
 guard let documents = snap?.documents else { return }
 self.categories.removeAll()
 for document in documents {
 let data = document.data()
 let newCategory = Category.init(data: data)
 self.categories.append(newCategory)
 }
 self.collectionView.reloadData()
 }

 collectionReference.getDocuments { (snap, error) in
 guard let documents = snap?.documents else { return }
 for document in documents {
 let data = document.data()
 let newCategory = Category.init(data: data)

 self.categories.append(newCategory)
 }
 self.collectionView.reloadData()
 }
 } */

