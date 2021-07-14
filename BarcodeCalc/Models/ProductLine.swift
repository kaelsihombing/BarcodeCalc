//
//  ProductLine.swift
//  BarcodeCalc
//
//  Created by Santo Michael Sihombing on 11/04/21.
//

import Foundation
import UIKit

class ProductLine {
    var name: String
    var products: [Product]
    
    init(name: String, includeProducts: [Product]) {
        self.name = name
        self.products = includeProducts
    }
    
    class func getProductLines() -> [ProductLine] {
//        return
    }
    
    private class func cosmetics() -> ProductLine {
//        var products = [Product]()
        
    }
}
