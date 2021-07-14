//
//  cardView.swift
//  BarcodeCalc
//
//  Created by Santo Michael Sihombing on 12/04/21.
//

import Foundation
import UIKit

@IBDesignable class DesignView: UIView {
    @IBInspectable var cornerRadius : CGFloat = 10
    
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    
    @IBInspectable var shadowOffSetWidth: Int = 0
    @IBInspectable var shadowOffSetHeight: Int = 1
    
    @IBInspectable var shadowOpacity : Float = 0.2
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        
        layer.shadowColor = shadowColor?.cgColor
        
        layer.shadowOffset = CGSize(width: shadowOffSetWidth, height: shadowOffSetHeight)
        
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.shadowPath = shadowPath.cgPath
        
        layer.shadowOpacity = shadowOpacity
    }
}
