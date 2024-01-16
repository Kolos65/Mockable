//
//  AssociatedTypeTests.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 21..
//

import MacroTesting
import XCTest

final class AssociatedTypeTests: MockableMacroTestCase {
    func test_associated_type() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              associatedtype Item
              func foo(item: Item) -> Item
          }
          """
        } expansion: {
            """
            protocol Test {
                associatedtype Item
                func foo(item: Item) -> Item
            }

            #if MOCKING
            final class MockTest<Item>: Test, Mockable {
                private var mocker = Mocker<MockTest>()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                func reset(_ scopes: Set<MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                init() {
                }
                func foo(item: Item) -> Item {
                    let member: Member = .m1_foo(item: .value(item))
                    return try! mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Item) -> Item
                        return producer(item)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_foo(item: Parameter<Item>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo(item: let leftItem), .m1_foo(item: let rightItem)):
                            return leftItem.match(rightItem)
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Item, (Item) -> Item> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func foo(item: Parameter<Item>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo(item: item), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_associated_type_with_inheritance() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              associatedtype Item: Equatable, Hashable
              func foo(item: Item) -> Item
          }
          """
        } expansion: {
            """
            protocol Test {
                associatedtype Item: Equatable, Hashable
                func foo(item: Item) -> Item
            }

            #if MOCKING
            final class MockTest<Item>: Test, Mockable where Item: Equatable, Item: Hashable {
                private var mocker = Mocker<MockTest>()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                func reset(_ scopes: Set<MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                init() {
                }
                func foo(item: Item) -> Item {
                    let member: Member = .m1_foo(item: .value(item))
                    return try! mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Item) -> Item
                        return producer(item)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_foo(item: Parameter<Item>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo(item: let leftItem), .m1_foo(item: let rightItem)):
                            return leftItem.match(rightItem)
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Item, (Item) -> Item> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func foo(item: Parameter<Item>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo(item: item), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_associated_type_with_where_clause() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              associatedtype Item where Item: Equatable, Item: Hashable
              func foo(item: Item) -> Item
          }
          """
        } expansion: {
            """
            protocol Test {
                associatedtype Item where Item: Equatable, Item: Hashable
                func foo(item: Item) -> Item
            }

            #if MOCKING
            final class MockTest<Item>: Test, Mockable where Item: Equatable, Item: Hashable {
                private var mocker = Mocker<MockTest>()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                func reset(_ scopes: Set<MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                init() {
                }
                func foo(item: Item) -> Item {
                    let member: Member = .m1_foo(item: .value(item))
                    return try! mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Item) -> Item
                        return producer(item)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_foo(item: Parameter<Item>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo(item: let leftItem), .m1_foo(item: let rightItem)):
                            return leftItem.match(rightItem)
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Item, (Item) -> Item> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func foo(item: Parameter<Item>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo(item: item), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }
}
