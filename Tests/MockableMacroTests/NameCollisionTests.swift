//
//  NameCollisionTests.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 21..
//

import MacroTesting
import XCTest

final class NameCollisionTests: MockableMacroTestCase {
    func test_same_name_different_type_params() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              func fetchData(for name: Int) -> String
              func fetchData(for name: String) -> String
          }
          """
        } expansion: {
            """
            protocol Test {
                func fetchData(for name: Int) -> String
                func fetchData(for name: String) -> String
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
                func fetchData(for name: Int) -> String {
                    let member: Member = .m1_fetchData(for: .value(name))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> String
                        return producer(name)
                    }
                }
                func fetchData(for name: String) -> String {
                    let member: Member = .m2_fetchData(for: .value(name))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (String) -> String
                        return producer(name)
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_fetchData(for: Parameter<Int>)
                    case m2_fetchData(for: Parameter<String>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_fetchData(for: let leftFor), .m1_fetchData(for: let rightFor)):
                            return leftFor.match(rightFor)
                        case (.m2_fetchData(for: let leftFor), .m2_fetchData(for: let rightFor)):
                            return leftFor.match(rightFor)
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
                    func fetchData(for name: Parameter<Int>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, String, (Int) -> String> {
                        .init(mocker, kind: .m1_fetchData(for: name))
                    }
                    func fetchData(for name: Parameter<String>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, String, (String) -> String> {
                        .init(mocker, kind: .m2_fetchData(for: name))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func fetchData(for name: Parameter<Int>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_fetchData(for: name))
                    }
                    func fetchData(for name: Parameter<String>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_fetchData(for: name))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func fetchData(for name: Parameter<Int>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_fetchData(for: name))
                    }
                    func fetchData(for name: Parameter<String>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_fetchData(for: name))
                    }
                }
            }
            #endif
            """
        }
    }

    func test_same_name_different_name_params() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              func fetchData(forA name: String) -> String
              func fetchData(forB name: String) -> String
          }
          """
        } expansion: {
            """
            protocol Test {
                func fetchData(forA name: String) -> String
                func fetchData(forB name: String) -> String
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
                func fetchData(forA name: String) -> String {
                    let member: Member = .m1_fetchData(forA: .value(name))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (String) -> String
                        return producer(name)
                    }
                }
                func fetchData(forB name: String) -> String {
                    let member: Member = .m2_fetchData(forB: .value(name))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (String) -> String
                        return producer(name)
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_fetchData(forA: Parameter<String>)
                    case m2_fetchData(forB: Parameter<String>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_fetchData(forA: let leftForA), .m1_fetchData(forA: let rightForA)):
                            return leftForA.match(rightForA)
                        case (.m2_fetchData(forB: let leftForB), .m2_fetchData(forB: let rightForB)):
                            return leftForB.match(rightForB)
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
                    func fetchData(forA name: Parameter<String>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, String, (String) -> String> {
                        .init(mocker, kind: .m1_fetchData(forA: name))
                    }
                    func fetchData(forB name: Parameter<String>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, String, (String) -> String> {
                        .init(mocker, kind: .m2_fetchData(forB: name))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func fetchData(forA name: Parameter<String>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_fetchData(forA: name))
                    }
                    func fetchData(forB name: Parameter<String>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_fetchData(forB: name))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func fetchData(forA name: Parameter<String>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_fetchData(forA: name))
                    }
                    func fetchData(forB name: Parameter<String>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_fetchData(forB: name))
                    }
                }
            }
            #endif
            """
        }
    }

    func test_reserved_keyword() {
        assertMacro {
            """
            @Mockable
            protocol Test {
                func `repeat`(param: Bool) -> String
            }
            """
        } expansion: {
            """
            protocol Test {
                func `repeat`(param: Bool) -> String
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
                func `repeat`(param: Bool) -> String {
                    let member: Member = .m1_repeat(param: .value(param))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Bool) -> String
                        return producer(param)
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_repeat(param: Parameter<Bool>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_repeat(param: let leftParam), .m1_repeat(param: let rightParam)):
                            return leftParam.match(rightParam)
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func `repeat`(param: Parameter<Bool>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, String, (Bool) -> String> {
                        .init(mocker, kind: .m1_repeat(param: param))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func `repeat`(param: Parameter<Bool>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_repeat(param: param))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func `repeat`(param: Parameter<Bool>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_repeat(param: param))
                    }
                }
            }
            #endif
            """
        }
    }
}


