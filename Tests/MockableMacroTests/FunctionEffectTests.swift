//
//  FunctionEffectTests.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 21..
//


import MacroTesting
import XCTest

final class FunctionEffectTests: MockableMacroTestCase {
    func test_throwing_function() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              func returnsAndThrows() throws -> String
              func canThrowError() throws
          }
          """
        } expansion: {
            """
            protocol Test {
                func returnsAndThrows() throws -> String
                func canThrowError() throws
            }

            #if MOCKING
            final class MockTest: Test, MockableService {
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
                func returnsAndThrows() throws -> String {
                    let member: Member = .m1_returnsAndThrows
                    return try mocker.mockThrowing(member) { producer in
                        let producer = try cast(producer) as () throws -> String
                        return try producer()
                    }
                }
                func canThrowError() throws {
                    let member: Member = .m2_canThrowError
                    try mocker.mockThrowing(member) { producer in
                        let producer = try cast(producer) as () throws -> Void
                        return try producer()
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_returnsAndThrows
                    case m2_canThrowError
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_returnsAndThrows, .m1_returnsAndThrows):
                            return true
                        case (.m2_canThrowError, .m2_canThrowError):
                            return true
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
                    func returnsAndThrows() -> ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, String, () throws -> String> {
                        .init(mocker, kind: .m1_returnsAndThrows)
                    }
                    func canThrowError() -> ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, Void, () throws -> Void> {
                        .init(mocker, kind: .m2_canThrowError)
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func returnsAndThrows() -> ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_returnsAndThrows)
                    }
                    func canThrowError() -> ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_canThrowError)
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func returnsAndThrows() -> ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_returnsAndThrows, assertion: assertion)
                    }
                    func canThrowError() -> ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_canThrowError, assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_rethrowing_function() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              func execute(operation: @escaping () throws -> Void) rethrows
          }
          """
        } expansion: {
            """
            protocol Test {
                func execute(operation: @escaping () throws -> Void) rethrows
            }

            #if MOCKING
            final class MockTest: Test, MockableService {
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
                func execute(operation: @escaping () throws -> Void) rethrows {
                    let member: Member = .m1_execute(operation: .value(operation))
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as (() throws -> Void) -> Void
                        return producer(operation)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_execute(operation: Parameter<() throws -> Void>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_execute(operation: let leftOperation), .m1_execute(operation: let rightOperation)):
                            return leftOperation.match(rightOperation)
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func execute(operation: Parameter<() throws -> Void>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Void, (() throws -> Void) -> Void> {
                        .init(mocker, kind: .m1_execute(operation: operation))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func execute(operation: Parameter<() throws -> Void>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_execute(operation: operation))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func execute(operation: Parameter<() throws -> Void>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_execute(operation: operation), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_async_function() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              func asyncFunction() async
              func asyncThrowingFunction() async throws
              func asyncParamFunction(param: @escaping () async throws -> Void) async throws
          }
          """
        } expansion: {
            """
            protocol Test {
                func asyncFunction() async
                func asyncThrowingFunction() async throws
                func asyncParamFunction(param: @escaping () async throws -> Void) async throws
            }

            #if MOCKING
            final class MockTest: Test, MockableService {
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
                func asyncFunction() async {
                    let member: Member = .m1_asyncFunction
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as () -> Void
                        return producer()
                    }
                }
                func asyncThrowingFunction() async throws {
                    let member: Member = .m2_asyncThrowingFunction
                    try mocker.mockThrowing(member) { producer in
                        let producer = try cast(producer) as () throws -> Void
                        return try producer()
                    }
                }
                func asyncParamFunction(param: @escaping () async throws -> Void) async throws {
                    let member: Member = .m3_asyncParamFunction(param: .value(param))
                    try mocker.mockThrowing(member) { producer in
                        let producer = try cast(producer) as (() async throws -> Void) throws -> Void
                        return try producer(param)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_asyncFunction
                    case m2_asyncThrowingFunction
                    case m3_asyncParamFunction(param: Parameter<() async throws -> Void>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_asyncFunction, .m1_asyncFunction):
                            return true
                        case (.m2_asyncThrowingFunction, .m2_asyncThrowingFunction):
                            return true
                        case (.m3_asyncParamFunction(param: let leftParam), .m3_asyncParamFunction(param: let rightParam)):
                            return leftParam.match(rightParam)
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
                    func asyncFunction() -> FunctionReturnBuilder<MockTest, ReturnBuilder, Void, () -> Void> {
                        .init(mocker, kind: .m1_asyncFunction)
                    }
                    func asyncThrowingFunction() -> ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, Void, () throws -> Void> {
                        .init(mocker, kind: .m2_asyncThrowingFunction)
                    }
                    func asyncParamFunction(param: Parameter<() async throws -> Void>) -> ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, Void, (() async throws -> Void) throws -> Void> {
                        .init(mocker, kind: .m3_asyncParamFunction(param: param))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func asyncFunction() -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_asyncFunction)
                    }
                    func asyncThrowingFunction() -> ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_asyncThrowingFunction)
                    }
                    func asyncParamFunction(param: Parameter<() async throws -> Void>) -> ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m3_asyncParamFunction(param: param))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func asyncFunction() -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_asyncFunction, assertion: assertion)
                    }
                    func asyncThrowingFunction() -> ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_asyncThrowingFunction, assertion: assertion)
                    }
                    func asyncParamFunction(param: Parameter<() async throws -> Void>) -> ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m3_asyncParamFunction(param: param), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }
}
