//
//  AccessModifierTests.swift
//
//
//  Created by Nayanda Haberty on 29/5/24.
//

import MacroTesting
import XCTest
import SwiftSyntax
@testable import Mockable

final class AccessModifierTests: MockableMacroTestCase {
    func test_public_modifier() {
        assertMacro {
            """
            @Mockable
            public protocol Test {
                init(id: String)
                var foo: Int { get }
                func bar(number: Int) -> Int
            }
            """
        } expansion: {
            """
            public protocol Test {
                init(id: String)
                var foo: Int { get }
                func bar(number: Int) -> Int
            }

            #if MOCKING
            public final class MockTest: Test, Mockable.MockableService {
                public typealias Mocker = Mockable.Mocker<MockTest>
                private let mocker = Mocker()
                @available(*, deprecated, message: "Use given(_ service:) instead. ")
                public nonisolated var _given: ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) instead. ")
                public nonisolated var _when: ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) instead. ")
                public nonisolated var _verify: VerifyBuilder {
                    .init(mocker: mocker)
                }
                public nonisolated func reset(_ scopes: Set<Mockable.MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                public nonisolated init(policy: Mockable.MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                public init(id: String) {
                }
                public func bar(number: Int) -> Int {
                    let member: Member = .m2_bar(number: .value(number))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> Int
                        return producer(number)
                    }
                }
                public var foo: Int {
                    get {
                        let member: Member = .m1_foo
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                public enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo
                    case m2_bar(number: Parameter<Int>)
                    public func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        case (.m2_bar(number: let leftNumber), .m2_bar(number: let rightNumber)):
                            return leftNumber.match(rightNumber)
                        default:
                            return false
                        }
                    }
                }
                public struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    public init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    public var foo: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_foo)
                    }
                    public func bar(number: Parameter<Int>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                public struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    public init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    public var foo: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                    public func bar(number: Parameter<Int>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                public struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    public init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    public var foo: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                    public func bar(number: Parameter<Int>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
            }
            #endif
            """
        }
    }

    func test_private_access_modifier() {
        assertMacro {
          """
          @Mockable
          private protocol Test {
              var foo: Int { get }
              func bar(number: Int) -> Int
          }
          """
        } expansion: {
            """
            private protocol Test {
                var foo: Int { get }
                func bar(number: Int) -> Int
            }

            #if MOCKING
            private final class MockTest: Test, Mockable.MockableService {
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
                func bar(number: Int) -> Int {
                    let member: Member = .m2_bar(number: .value(number))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> Int
                        return producer(number)
                    }
                }
                var foo: Int {
                    get {
                        let member: Member = .m1_foo
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo
                    case m2_bar(number: Parameter<Int>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        case (.m2_bar(number: let leftNumber), .m2_bar(number: let rightNumber)):
                            return leftNumber.match(rightNumber)
                        default:
                            return false
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var foo: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_foo)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var foo: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var foo: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_bar(number: number))
                    }
                }
            }
            #endif
            """
        }
    }

    func test_mutating_modifier_filtered() {
        assertMacro {
            """
            @Mockable
            public protocol Test {
                mutating nonisolated func foo()
            }
            """
        } expansion: {
            """
            public protocol Test {
                mutating nonisolated func foo()
            }

            #if MOCKING
            public final class MockTest: Test, Mockable.MockableService {
                public typealias Mocker = Mockable.Mocker<MockTest>
                private let mocker = Mocker()
                @available(*, deprecated, message: "Use given(_ service:) instead. ")
                public nonisolated var _given: ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) instead. ")
                public nonisolated var _when: ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) instead. ")
                public nonisolated var _verify: VerifyBuilder {
                    .init(mocker: mocker)
                }
                public nonisolated func reset(_ scopes: Set<Mockable.MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                public nonisolated init(policy: Mockable.MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                public nonisolated func foo() {
                    let member: Member = .m1_foo
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as () -> Void
                        return producer()
                    }
                }
                public enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo
                    public func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        }
                    }
                }
                public struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    public init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    public func foo() -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Void, () -> Void> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                public struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    public init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    public func foo() -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                public struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    public init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    public func foo() -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
            }
            #endif
            """
        }
    }
}
