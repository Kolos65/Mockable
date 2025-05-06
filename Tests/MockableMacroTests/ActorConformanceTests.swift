//
//  ActorConformanceTests.swift
//  
//
//  Created by Kolos Foltanyi on 06/07/2024.
//

import MacroTesting
import XCTest
import SwiftSyntax
@testable import Mockable

final class ActorConformanceTests: MockableMacroTestCase {
    func test_global_actor_conformance() {
        assertMacro {
          """
          @MainActor
          @Mockable
          protocol Test {
              var foo: Int { get }
              nonisolated var quz: Int { get }
              func bar(number: Int) -> Int
              nonisolated func baz(number: Int) -> Int
          }
          """
        } expansion: {
            """
            @MainActor
            protocol Test {
                var foo: Int { get }
                nonisolated var quz: Int { get }
                func bar(number: Int) -> Int
                nonisolated func baz(number: Int) -> Int
            }

            #if MOCKING
            final class MockTest: Test, Mockable.MockableService {
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
                    let member: Member = .m3_bar(number: .value(number))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> Int
                        return producer(number)
                    }
                }
                nonisolated func baz(number: Int) -> Int {
                    let member: Member = .m4_baz(number: .value(number))
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
                nonisolated var quz: Int {
                    get {
                        let member: Member = .m2_quz
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo
                    case m2_quz
                    case m3_bar(number: Parameter<Int>)
                    case m4_baz(number: Parameter<Int>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        case (.m2_quz, .m2_quz):
                            return true
                        case (.m3_bar(number: let leftNumber), .m3_bar(number: let rightNumber)):
                            return leftNumber.match(rightNumber)
                        case (.m4_baz(number: let leftNumber), .m4_baz(number: let rightNumber)):
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
                    var quz: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m2_quz)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m3_bar(number: number))
                    }
                    func baz(number: Parameter<Int>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m4_baz(number: number))
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
                    var quz: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_quz)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m3_bar(number: number))
                    }
                    func baz(number: Parameter<Int>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m4_baz(number: number))
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
                    var quz: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_quz)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m3_bar(number: number))
                    }
                    func baz(number: Parameter<Int>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m4_baz(number: number))
                    }
                }
            }
            #endif
            """
        }
    }
    func test_actor_requirement() {
        assertMacro {
          """
          @Mockable
          protocol Test: Actor {
              var foo: Int { get }
              nonisolated var quz: Int { get }
              func bar(number: Int) -> Int
              nonisolated func baz(number: Int) -> Int
          }
          """
        } expansion: {
            """
            protocol Test: Actor {
                var foo: Int { get }
                nonisolated var quz: Int { get }
                func bar(number: Int) -> Int
                nonisolated func baz(number: Int) -> Int
            }

            #if MOCKING
            actor MockTest: Test, Mockable.MockableService {
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
                init(policy: Mockable.MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                func bar(number: Int) -> Int {
                    let member: Member = .m3_bar(number: .value(number))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> Int
                        return producer(number)
                    }
                }
                nonisolated func baz(number: Int) -> Int {
                    let member: Member = .m4_baz(number: .value(number))
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
                nonisolated var quz: Int {
                    get {
                        let member: Member = .m2_quz
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo
                    case m2_quz
                    case m3_bar(number: Parameter<Int>)
                    case m4_baz(number: Parameter<Int>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        case (.m2_quz, .m2_quz):
                            return true
                        case (.m3_bar(number: let leftNumber), .m3_bar(number: let rightNumber)):
                            return leftNumber.match(rightNumber)
                        case (.m4_baz(number: let leftNumber), .m4_baz(number: let rightNumber)):
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
                    var quz: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m2_quz)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m3_bar(number: number))
                    }
                    func baz(number: Parameter<Int>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, (Int) -> Int> {
                        .init(mocker, kind: .m4_baz(number: number))
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
                    var quz: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_quz)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m3_bar(number: number))
                    }
                    func baz(number: Parameter<Int>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m4_baz(number: number))
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
                    var quz: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_quz)
                    }
                    func bar(number: Parameter<Int>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m3_bar(number: number))
                    }
                    func baz(number: Parameter<Int>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m4_baz(number: number))
                    }
                }
            }
            #endif
            """
        }
    }
}
