//
//  ProductItems+CoreDataProperties.swift
//  BarcodeCalc
//
//  Created by Santo Michael Sihombing on 11/04/21.
//
//

import Foundation
import CoreData


extension ProductItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductItems> {
        return NSFetchRequest<ProductItems>(entityName: "ProductItems")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var price: Int64

}

extension ProductItems : Identifiable {

}
