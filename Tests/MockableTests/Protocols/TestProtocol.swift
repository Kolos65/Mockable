//
//  TestProtocol.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 21..
//

import MockableTest

@Mockable
protocol TestProtocol: Sendable where Item2: Identifiable {

    // MARK: Associated Types

    associatedtype Item1
    associatedtype Item2: Equatable, Hashable
    associatedtype Item3 where Item3: Equatable, Item3: Hashable

    func foo(item1: Item1) -> Item1
    func foo(item2: Item2) -> Item2
    func foo(item3: Item3) -> Item3

    // MARK: Exotic Parameters

    func modifyValue(_ value: inout Int)
    func printValues(_ values: Int...)
    func execute(operation: @escaping () throws -> Void)

    // MARK: Function Effects

    func canThrowError() throws
    func returnsAndThrows() throws -> String
    func call(operation: @escaping () throws -> Void) rethrows
    func asyncFunction() async
    func asyncThrowingFunction() async throws
    func asyncParamFunction(param: @escaping () async throws -> Void) async

    // MARK: Generic Functions

    func foo<T>(item: (Array<[(Set<T>, String)]>, Int))
    func genericFunc<T, V>(item: T) -> V
    func method<T: Hashable, E, C, I>(
        prop1: T, prop2: E, prop3: C, prop4: I
    ) where E: Equatable, E: Hashable, C: Codable

    // MARK: Name Collision

    func fetchData(for name: Int) -> String
    func fetchData(for name: String) -> String
    func fetchData(forA name: String) -> String
    func fetchData(forB name: String) -> String
    func `repeat`(param: Bool) -> Int

    // MARK: Property Requirements

    var computedInt: Int { get }
    var computedString: String { get }
    var mutableInt: Int { get set }
    var mutableUnwrappedString: String! { get set }
    var throwingProperty: Int { get throws }
    var asyncProperty: String { get async }
    var asyncThrowingProperty: String { get async throws }

    // MARK: Init

    init?() async throws
    init(index: Int)
    init(name value: String, index: Int)

    // MARK: Attributes

    @available(iOS 15, *)
    init(attributed: String)

    @available(iOS 15, *)
    var attributedProp: Int { get }

    @available(iOS 15, *)
    func attributedTest()
}
