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
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
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
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func returnsAndThrows() -> Mockable.ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, String, any Error, () throws -> String> {
                        .init(mocker, kind: .m1_returnsAndThrows)
                    }
                    func canThrowError() -> Mockable.ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, Void, any Error, () throws -> Void> {
                        .init(mocker, kind: .m2_canThrowError)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func returnsAndThrows() -> Mockable.ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_returnsAndThrows)
                    }
                    func canThrowError() -> Mockable.ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_canThrowError)
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func returnsAndThrows() -> Mockable.ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_returnsAndThrows)
                    }
                    func canThrowError() -> Mockable.ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_canThrowError)
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
                func execute(operation: @escaping () throws -> Void) rethrows {
                    let member: Member = .m1_execute(operation: .value(operation))
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as (@escaping () throws -> Void) -> Void
                        return producer(operation)
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_execute(operation: Parameter<() throws -> Void>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_execute(operation: let leftOperation), .m1_execute(operation: let rightOperation)):
                            return leftOperation.match(rightOperation)
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func execute(operation: Parameter<() throws -> Void>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Void, (@escaping () throws -> Void) -> Void> {
                        .init(mocker, kind: .m1_execute(operation: operation))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func execute(operation: Parameter<() throws -> Void>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_execute(operation: operation))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func execute(operation: Parameter<() throws -> Void>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_execute(operation: operation))
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
                        let producer = try cast(producer) as (@escaping () async throws -> Void) throws -> Void
                        return try producer(param)
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
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
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func asyncFunction() -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Void, () -> Void> {
                        .init(mocker, kind: .m1_asyncFunction)
                    }
                    func asyncThrowingFunction() -> Mockable.ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, Void, any Error, () throws -> Void> {
                        .init(mocker, kind: .m2_asyncThrowingFunction)
                    }
                    func asyncParamFunction(param: Parameter<() async throws -> Void>) -> Mockable.ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, Void, any Error, (@escaping () async throws -> Void) throws -> Void> {
                        .init(mocker, kind: .m3_asyncParamFunction(param: param))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func asyncFunction() -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_asyncFunction)
                    }
                    func asyncThrowingFunction() -> Mockable.ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_asyncThrowingFunction)
                    }
                    func asyncParamFunction(param: Parameter<() async throws -> Void>) -> Mockable.ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m3_asyncParamFunction(param: param))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func asyncFunction() -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_asyncFunction)
                    }
                    func asyncThrowingFunction() -> Mockable.ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_asyncThrowingFunction)
                    }
                    func asyncParamFunction(param: Parameter<() async throws -> Void>) -> Mockable.ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m3_asyncParamFunction(param: param))
                    }
                }
            }
            #endif
            """
        }
    }
}
