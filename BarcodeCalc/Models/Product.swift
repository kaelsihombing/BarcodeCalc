//
//  Product.swift
//  BarcodeCalc
//
//  Created by Santo Michael Sihombing on 11/04/21.
//

import UIKit
import Foundation

//Product

class Product {
//    var image: UIImage
    var id: Int32
    var title: String
    var price: Int32
    
    init(id: Int32, title: String, price: Int32) {
        self.id = id
        self.title = title
        self.price = price
//
//        if let image = UIImage(named: imageName) {
//            self.image = image
//        } else {
//            self.image = UIImage(named: "default")!
//        }
    }
}
