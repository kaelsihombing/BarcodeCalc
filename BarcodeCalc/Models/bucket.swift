//
//  bucket.swift
//  BarcodeCalc
//
//  Created by Santo Michael Sihombing on 12/04/21.
//

import Foundation

class Bucket {
    let title: String
    let price: Int64
    let amount: Int
    var total: Int64
    
    init(title: String, price: Int64, amount: Int, total: Int64) {
        self.title = title
        self.price = price
        self.amount = amount
        self.total = total
    }
    
}

//struct Buckets {
//    let buckets: [Bucket]
//    var totalPrice: Int64
//    
//    mutating func total(buckets: [Bucket]) {
//        for i in buckets {
//            totalPrice += Int64(i.totals())
//        }
//    }
//    
//}
