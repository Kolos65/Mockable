//
//  UserService.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 24..
//

import MockableTest
import Foundation

@Mockable
protocol UserService {

    // MARK: Associated Type

    associatedtype Color
    func getFavoriteColor() -> Color

    // MARK: Properties

    var name: String { get set }
    var optional: String? { get set }

    // MARK: Functions

    func getUser(for id: UUID) throws -> User
    func getUsers(for ids: UUID...) -> [User]
    func setUser(user: User) async throws -> Bool
    func modify(user: User) -> Int
    func update(products: [Product]) -> Int
    func print() throws

    // MARK: Generics

    func getUserAndValue<Value>(for id: UUID, value: Value) -> (User, Value)
    func delete<T>(for value: T) -> Int
    func retrieve<V>() -> V
    func retrieveItem<T, V>(item: T) -> V
}
