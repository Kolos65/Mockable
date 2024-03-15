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
            final class MockTest: Test, Mockable {
                private var mocker = Mocker<MockTest>()
                @available(*, deprecated, message: "Use given(_ service:) of MockableTest instead.")
                func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of MockableTest instead.")
                func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead.")
                func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                func reset(_ scopes: Set<MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                init() {
                }
                init(strict: Bool) {
                    mocker.strict = strict
                }
                func fetchData(for name: Int) -> String {
                    let member: Member = .m1_fetchData(for: .value(name))
                    return try! mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> String
                        return producer(name)
                    }
                }
                func fetchData(for name: String) -> String {
                    let member: Member = .m2_fetchData(for: .value(name))
                    return try! mocker.mock(member) { producer in
                        let producer = try cast(producer) as (String) -> String
                        return producer(name)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
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
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func fetchData(for name: Parameter<Int>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, String, (Int) -> String> {
                        .init(mocker, kind: .m1_fetchData(for: name))
                    }
                    func fetchData(for name: Parameter<String>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, String, (String) -> String> {
                        .init(mocker, kind: .m2_fetchData(for: name))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func fetchData(for name: Parameter<Int>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_fetchData(for: name))
                    }
                    func fetchData(for name: Parameter<String>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_fetchData(for: name))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func fetchData(for name: Parameter<Int>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_fetchData(for: name), assertion: assertion)
                    }
                    func fetchData(for name: Parameter<String>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_fetchData(for: name), assertion: assertion)
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
            final class MockTest: Test, Mockable {
                private var mocker = Mocker<MockTest>()
                @available(*, deprecated, message: "Use given(_ service:) of MockableTest instead.")
                func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of MockableTest instead.")
                func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead.")
                func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                func reset(_ scopes: Set<MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                init() {
                }
                init(strict: Bool) {
                    mocker.strict = strict
                }
                func fetchData(forA name: String) -> String {
                    let member: Member = .m1_fetchData(forA: .value(name))
                    return try! mocker.mock(member) { producer in
                        let producer = try cast(producer) as (String) -> String
                        return producer(name)
                    }
                }
                func fetchData(forB name: String) -> String {
                    let member: Member = .m2_fetchData(forB: .value(name))
                    return try! mocker.mock(member) { producer in
                        let producer = try cast(producer) as (String) -> String
                        return producer(name)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
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
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func fetchData(forA name: Parameter<String>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, String, (String) -> String> {
                        .init(mocker, kind: .m1_fetchData(forA: name))
                    }
                    func fetchData(forB name: Parameter<String>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, String, (String) -> String> {
                        .init(mocker, kind: .m2_fetchData(forB: name))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func fetchData(forA name: Parameter<String>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_fetchData(forA: name))
                    }
                    func fetchData(forB name: Parameter<String>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_fetchData(forB: name))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func fetchData(forA name: Parameter<String>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_fetchData(forA: name), assertion: assertion)
                    }
                    func fetchData(forB name: Parameter<String>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_fetchData(forB: name), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }
}


