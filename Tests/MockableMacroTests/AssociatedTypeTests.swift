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
            final class MockTest<Item>: Test, Mockable.MockableService {
                typealias Mocker = Mockable.Mocker<MockTest>
                private let mocker = Mocker()
                @available(*, deprecated, message: "Use given(_ service:) instead. ")
                nonisolated var _given: ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) instead. ")
                nonisolated var _when: ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) instead. ")
                nonisolated var _verify: VerifyBuilder {
                    .init(mocker: mocker)
                }
                nonisolated func reset(_ scopes: Set<Mockable.MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                nonisolated init(policy: Mockable.MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                func foo(item: Item) -> Item {
                    let member: Member = .m1_foo(item: .value(item))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Item) -> Item
                        return producer(item)
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo(item: Parameter<Item>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo(item: let leftItem), .m1_foo(item: let rightItem)):
                            return leftItem.match(rightItem)
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Item, (Item) -> Item> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo(item: item))
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
            final class MockTest<Item>: Test, Mockable.MockableService where Item: Equatable, Item: Hashable {
                typealias Mocker = Mockable.Mocker<MockTest>
                private let mocker = Mocker()
                @available(*, deprecated, message: "Use given(_ service:) instead. ")
                nonisolated var _given: ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) instead. ")
                nonisolated var _when: ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) instead. ")
                nonisolated var _verify: VerifyBuilder {
                    .init(mocker: mocker)
                }
                nonisolated func reset(_ scopes: Set<Mockable.MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                nonisolated init(policy: Mockable.MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                func foo(item: Item) -> Item {
                    let member: Member = .m1_foo(item: .value(item))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Item) -> Item
                        return producer(item)
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo(item: Parameter<Item>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo(item: let leftItem), .m1_foo(item: let rightItem)):
                            return leftItem.match(rightItem)
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Item, (Item) -> Item> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo(item: item))
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
            final class MockTest<Item>: Test, Mockable.MockableService where Item: Equatable, Item: Hashable {
                typealias Mocker = Mockable.Mocker<MockTest>
                private let mocker = Mocker()
                @available(*, deprecated, message: "Use given(_ service:) instead. ")
                nonisolated var _given: ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) instead. ")
                nonisolated var _when: ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) instead. ")
                nonisolated var _verify: VerifyBuilder {
                    .init(mocker: mocker)
                }
                nonisolated func reset(_ scopes: Set<Mockable.MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                nonisolated init(policy: Mockable.MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                func foo(item: Item) -> Item {
                    let member: Member = .m1_foo(item: .value(item))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Item) -> Item
                        return producer(item)
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo(item: Parameter<Item>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo(item: let leftItem), .m1_foo(item: let rightItem)):
                            return leftItem.match(rightItem)
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Item, (Item) -> Item> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo(item: Parameter<Item>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo(item: item))
                    }
                }
            }
            #endif
            """
        }
    }
}
