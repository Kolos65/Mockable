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
                func foo<T>(item: (Array<[(Set<T>, String)]>, Int)) {
                    let member: Member = .m1_foo(item: .generic(item))
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as ((Array<[(Set<T>, String)]>, Int)) -> Void
                        return producer(item)
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo(item: Parameter<GenericValue>)
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
                    func foo<T>(item: Parameter<(Array<[(Set<T>, String)]>, Int)>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Void, ((Array<[(Set<T>, String)]>, Int)) -> Void> {
                        .init(mocker, kind: .m1_foo(item: item.eraseToGenericValue()))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo<T>(item: Parameter<(Array<[(Set<T>, String)]>, Int)>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo(item: item.eraseToGenericValue()))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo<T>(item: Parameter<(Array<[(Set<T>, String)]>, Int)>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo(item: item.eraseToGenericValue()))
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
                func genericFunc<T, V>(item: T) -> V {
                    let member: Member = .m1_genericFunc(item: .generic(item))
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as (T) -> V
                        return producer(item)
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_genericFunc(item: Parameter<GenericValue>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_genericFunc(item: let leftItem), .m1_genericFunc(item: let rightItem)):
                            return leftItem.match(rightItem)
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func genericFunc<T, V>(item: Parameter<T>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, V, (T) -> V> {
                        .init(mocker, kind: .m1_genericFunc(item: item.eraseToGenericValue()))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func genericFunc<T>(item: Parameter<T>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_genericFunc(item: item.eraseToGenericValue()))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func genericFunc<T>(item: Parameter<T>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_genericFunc(item: item.eraseToGenericValue()))
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
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_method1(p1: Parameter<GenericValue>, p2: Parameter<GenericValue>, p3: Parameter<GenericValue>, p4: Parameter<GenericValue>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_method1(p1: let leftP1, p2: let leftP2, p3: let leftP3, p4: let leftP4), .m1_method1(p1: let rightP1, p2: let rightP2, p3: let rightP3, p4: let rightP4)):
                            return leftP1.match(rightP1) && leftP2.match(rightP2) && leftP3.match(rightP3) && leftP4.match(rightP4)
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func method1<T: Hashable, E, C, I>(
                            p1: Parameter<T>, p2: Parameter<E>, p3: Parameter<C>, p4: Parameter<I>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Void, (T, E, C, I) -> Void> where E: Equatable, E: Hashable, C: Codable {
                        .init(mocker, kind: .m1_method1(p1:
                                p1.eraseToGenericValue(), p2: p2.eraseToGenericValue(), p3: p3.eraseToGenericValue(), p4: p4.eraseToGenericValue()))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func method1<T: Hashable, E, C, I>(
                            p1: Parameter<T>, p2: Parameter<E>, p3: Parameter<C>, p4: Parameter<I>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> where E: Equatable, E: Hashable, C: Codable {
                        .init(mocker, kind: .m1_method1(p1:
                                p1.eraseToGenericValue(), p2: p2.eraseToGenericValue(), p3: p3.eraseToGenericValue(), p4: p4.eraseToGenericValue()))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func method1<T: Hashable, E, C, I>(
                            p1: Parameter<T>, p2: Parameter<E>, p3: Parameter<C>, p4: Parameter<I>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> where E: Equatable, E: Hashable, C: Codable {
                        .init(mocker, kind: .m1_method1(p1:
                                p1.eraseToGenericValue(), p2: p2.eraseToGenericValue(), p3: p3.eraseToGenericValue(), p4: p4.eraseToGenericValue()))
                    }
                }
            }
            #endif
            """
        }
    }

    func test_parametrized_protocol_requirements_in_variables() {
        assertMacro {
        """
        @Mockable
        protocol Test {
            var prop: any SomeProtocol<String> { get }
        }
        """
        } expansion: {
            """
            protocol Test {
                var prop: any SomeProtocol<String> { get }
            }

            #if MOCKING
            @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
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
                var prop: any SomeProtocol<String> {
                    get {
                        let member: Member = .m1_prop
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> any SomeProtocol<String>
                            return producer()
                        }
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_prop
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_prop, .m1_prop):
                            return true
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var prop: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, any SomeProtocol<String>, () -> any SomeProtocol<String>> {
                        .init(mocker, kind: .m1_prop)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var prop: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_prop)
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var prop: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_prop)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_nested_parametrized_protocol_requirements_in_variables() {
        assertMacro {
        """
        @Mockable
        protocol Test {
            var prop: Parent<String, Child<any SomeProtocol<Double>>> { get }
        }
        """
        } expansion: {
            """
            protocol Test {
                var prop: Parent<String, Child<any SomeProtocol<Double>>> { get }
            }

            #if MOCKING
            @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
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
                var prop: Parent<String, Child<any SomeProtocol<Double>>> {
                    get {
                        let member: Member = .m1_prop
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Parent<String, Child<any SomeProtocol<Double>>>
                            return producer()
                        }
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_prop
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_prop, .m1_prop):
                            return true
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var prop: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Parent<String, Child<any SomeProtocol<Double>>>, () -> Parent<String, Child<any SomeProtocol<Double>>>> {
                        .init(mocker, kind: .m1_prop)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var prop: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_prop)
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var prop: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_prop)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_parametrized_protocol_requirements_in_functions() {
        assertMacro {
        """
        @Mockable
        protocol Test {
            func foo() -> any SomeProtocol<Double>
        }
        """
        } expansion: {
            """
            protocol Test {
                func foo() -> any SomeProtocol<Double>
            }

            #if MOCKING
            @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
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
                func foo() -> any SomeProtocol<Double> {
                    let member: Member = .m1_foo
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as () -> any SomeProtocol<Double>
                        return producer()
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo() -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, any SomeProtocol<Double>, () -> any SomeProtocol<Double>> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo() -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo() -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_nested_parametrized_protocol_requirements_in_functions() {
        assertMacro {
        """
        @Mockable
        protocol Test {
            func foo() -> Parent<String, Child<any SomeProtocol<Double>>>
        }
        """
        } expansion: {
            """
            protocol Test {
                func foo() -> Parent<String, Child<any SomeProtocol<Double>>>
            }

            #if MOCKING
            @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
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
                func foo() -> Parent<String, Child<any SomeProtocol<Double>>> {
                    let member: Member = .m1_foo
                    return mocker.mock(member) { producer in
                        let producer = try cast(producer) as () -> Parent<String, Child<any SomeProtocol<Double>>>
                        return producer()
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo() -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Parent<String, Child<any SomeProtocol<Double>>>, () -> Parent<String, Child<any SomeProtocol<Double>>>> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo() -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo() -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
            }
            #endif
            """
        }
    }
}
