//
//  ProductsVC.swift
//  Artable
//
//  Created by Angelina on 6/24/19.
//  Copyright © 2019 Angelina Friz. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ProductsVC: UIViewController, ProductCellDelegate {

    // 1
    @IBOutlet weak var tableView: UITableView!
    // 2
    var products = [Product]()

    // 7
    var category: Category!
    var listener: ListenerRegistration!
    var db: Firestore!
    var showFavorites = false 

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()

//        let product = Product.init(name: "Girl", id: "fhfhg", category: "Portraits", price: 24.99, productDescription: "A pour beauty", imageUrl: "https://images.unsplash.com/photo-1464863979621-258859e62245?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=933&q=80", timeStamp: Timestamp(), stock: 0)
//        products.append(product)
        // 4
        tableView.delegate = self
        tableView.dataSource = self
        // 6
        tableView.register(UINib(nibName: Identifiers.ProductCell, bundle: nil), forCellReuseIdentifier: Identifiers.ProductCell)
        setupQuery()
    }

    func setupQuery() {

        var ref: Query!
        if showFavorites {
            ref = db.collection("users").document(UserService.user.id).collection("favorites")
        } else {
            ref = db.products(category: category.id)
        }

        listener = ref.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let product = Product.init(data: data)

                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, product: product)
                case .modified:
                    self.onDocumentModified(change: change, product: product)
                case .removed:
                    self.onDocumentRemoved(change: change)
                @unknown default:
                    fatalError()
                }
            })
        })
    }

    func productFavorited(product: Product) {
        UserService.favoriteSelected(product: product)
        // taking the `of:product` and go through products array until it
        // finds one that matches and then returns that index
        guard let index = products.firstIndex(of: product) else { return }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func productAddToCart(product: Product) {
        StripeCart.addItemToCart(item: product)
    }
}
// 3
extension ProductsVC: UITableViewDelegate, UITableViewDataSource {
    func onDocumentAdded(change: DocumentChange, product: Product) {
        let newIndex = Int(change.newIndex)
        products.insert(product, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .fade)
    }

    func onDocumentModified(change: DocumentChange, product: Product) {
        if change.oldIndex == change.newIndex {
            let index = Int(change.newIndex)
            products[index] = product
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            products.remove(at: oldIndex)
            products.insert(product, at: newIndex)
            tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }

    }

    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        products.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .left)

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.ProductCell, for: indexPath) as? ProductCell {

            cell.configireCell(product: products[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ProductDetailVC()
        let selectedProduct = products[indexPath.row]
        vc.product = selectedProduct
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
// 5
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }


}
