//
//  ProductTableViewCell.swift
//  BarcodeCalc
//
//  Created by Santo Michael Sihombing on 12/04/21.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
//    Data model
    var product: ProductItems? {
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI() {
        idLabel?.text = String(product!.id)
        titleLabel?.text = product?.title
        priceLabel?.text = String(product!.price)
    }
    
    
    
    
    
    
}
