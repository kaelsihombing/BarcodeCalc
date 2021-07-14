//
//  BucketTableViewCell.swift
//  BarcodeCalc
//
//  Created by Santo Michael Sihombing on 12/04/21.
//

import Foundation
import UIKit


class BucketTableViewCell: UITableViewCell {
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    var product: Bucket? {
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI() {
        productNameLabel?.text = String(product!.title)
        amountLabel?.text = String(product!.amount)
        priceLabel?.text = String(product!.price)
        totalLabel?.text = String(product!.total)
    }
}
