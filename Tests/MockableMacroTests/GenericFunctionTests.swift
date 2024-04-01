//
//  GenericFunctionTests.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 21..
//

import MacroTesting
import XCTest

final class GenericFunctionTests: MockableMacroTestCase {
    func test_deeply_nested_generic_parameter() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              func foo<T>(item: (Array<[(Set<T>, String)]>, Int))
          }
          """
        } expansion: {
            """
            protocol Test {
                func foo<T>(item: (Array<[(Set<T>, String)]>, Int))
            }

            #if MOCKING
            final class MockTest: Test, Mockable {
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
                init(policy: MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                func foo<T>(item: (Array<[(Set<T>, String)]>, Int)) {
                    let member: Member = .m1_foo(item: .generic(item))
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as ((Array<[(Set<T>, String)]>, Int)) -> Void
                        return producer(item)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_foo(item: Parameter<GenericValue>)
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
                    func foo<T>(item: Parameter<(Array<[(Set<T>, String)]>, Int)>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Void, ((Array<[(Set<T>, String)]>, Int)) -> Void> {
                        .init(mocker, kind: .m1_foo(item: item.eraseToGenericValue()))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func foo<T>(item: Parameter<(Array<[(Set<T>, String)]>, Int)>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo(item: item.eraseToGenericValue()))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func foo<T>(item: Parameter<(Array<[(Set<T>, String)]>, Int)>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo(item: item.eraseToGenericValue()), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_generic_param_and_return() {
        assertMacro {
            """
            @Mockable
            protocol Test {
                func genericFunc<T, V>(item: T) -> V
            }
            """
        } expansion: {
            """
            protocol Test {
                func genericFunc<T, V>(item: T) -> V
            }

            #if MOCKING
            final class MockTest: Test, Mockable {
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
                init(policy: MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                func genericFunc<T, V>(item: T) -> V {
                    let member: Member = .m1_genericFunc(item: .generic(item))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (T) -> V
                        return producer(item)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_genericFunc(item: Parameter<GenericValue>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_genericFunc(item: let leftItem), .m1_genericFunc(item: let rightItem)):
                            return leftItem.match(rightItem)
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func genericFunc<T, V>(item: Parameter<T>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, V, (T) -> V> {
                        .init(mocker, kind: .m1_genericFunc(item: item.eraseToGenericValue()))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func genericFunc<T>(item: Parameter<T>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_genericFunc(item: item.eraseToGenericValue()))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func genericFunc<T>(item: Parameter<T>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_genericFunc(item: item.eraseToGenericValue()), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_constrained_generic_params() {
        assertMacro {
            """
            @Mockable
            protocol Test {
                func method1<T: Hashable, E, C, I>(
                    p1: T, p2: E, p3: C, p4: I
                ) where E: Equatable, E: Hashable, C: Codable
            }
            """
        } expansion: {
            """
            protocol Test {
                func method1<T: Hashable, E, C, I>(
                    p1: T, p2: E, p3: C, p4: I
                ) where E: Equatable, E: Hashable, C: Codable
            }

            #if MOCKING
            final class MockTest: Test, Mockable {
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
                init(policy: MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                func method1<T: Hashable, E, C, I>(
                        p1: T, p2: E, p3: C, p4: I
                    ) where E: Equatable, E: Hashable, C: Codable {
                    let member: Member = .m1_method1(p1: .generic(
                            p1), p2: .generic(p2), p3: .generic(p3), p4: .generic(p4))
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as (T, E, C, I) -> Void
                        return producer(p1, p2, p3, p4)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_method1(p1: Parameter<GenericValue>, p2: Parameter<GenericValue>, p3: Parameter<GenericValue>, p4: Parameter<GenericValue>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_method1(p1: let leftP1, p2: let leftP2, p3: let leftP3, p4: let leftP4), .m1_method1(p1: let rightP1, p2: let rightP2, p3: let rightP3, p4: let rightP4)):
                            return leftP1.match(rightP1) && leftP2.match(rightP2) && leftP3.match(rightP3) && leftP4.match(rightP4)
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func method1<T: Hashable, E, C, I>(
                            p1: Parameter<T>, p2: Parameter<E>, p3: Parameter<C>, p4: Parameter<I>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Void, (T, E, C, I) -> Void> where E: Equatable, E: Hashable, C: Codable {
                        .init(mocker, kind: .m1_method1(p1:
                                p1.eraseToGenericValue(), p2: p2.eraseToGenericValue(), p3: p3.eraseToGenericValue(), p4: p4.eraseToGenericValue()))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func method1<T: Hashable, E, C, I>(
                            p1: Parameter<T>, p2: Parameter<E>, p3: Parameter<C>, p4: Parameter<I>) -> FunctionActionBuilder<MockTest, ActionBuilder> where E: Equatable, E: Hashable, C: Codable {
                        .init(mocker, kind: .m1_method1(p1:
                                p1.eraseToGenericValue(), p2: p2.eraseToGenericValue(), p3: p3.eraseToGenericValue(), p4: p4.eraseToGenericValue()))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func method1<T: Hashable, E, C, I>(
                            p1: Parameter<T>, p2: Parameter<E>, p3: Parameter<C>, p4: Parameter<I>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> where E: Equatable, E: Hashable, C: Codable {
                        .init(mocker, kind: .m1_method1(p1:
                                p1.eraseToGenericValue(), p2: p2.eraseToGenericValue(), p3: p3.eraseToGenericValue(), p4: p4.eraseToGenericValue()), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }
}
