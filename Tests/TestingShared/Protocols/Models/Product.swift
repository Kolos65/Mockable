//
//  Product.swift
//  
//
//  Created by Kolos Foltanyi on 2023. 11. 26..
//

import Foundation

struct Product {
    var id = UUID()
    var name: String

    static let test = Product(name: "product1")
}
