//
//  User.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 26..
//

import Foundation

struct User: Equatable, Hashable {
    let id = UUID()
    let name: String
    var age: Int

    static let test1: User = .init(name: "test1", age: 1)
    static let test2: User = .init(name: "test2", age: 2)
    static let test3: User = .init(name: "test3", age: 3)
    static let list: [User] = [
        .init(name: "test1", age: 1),
        .init(name: "test2", age: 2),
        .init(name: "test3", age: 3),
        .init(name: "test4", age: 4)
    ]
}
