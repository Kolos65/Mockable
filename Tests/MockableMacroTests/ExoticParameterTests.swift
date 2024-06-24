//
//  ExoticParameterTests.swift
//  
//
//  Created by Kolos Foltanyi on 2023. 11. 21..
//

import MacroTesting
import XCTest

final class ExoticParameterTests: MockableMacroTestCase {
    func test_inout_parameter() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              func modifyValue(_ value: inout Int)
          }
          """
        } expansion: {
            """
            protocol Test {
                func modifyValue(_ value: inout Int)
            }

            #if MOCKING
            final class MockTest: Test, MockableService {
                private let mocker = Mocker<MockTest>()
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
                func modifyValue(_ value: inout Int) {
                    let member: Member = .m1_modifyValue(.value(value))
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as (Int) -> Void
                        return producer(value)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_modifyValue(Parameter<Int>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_modifyValue(let leftParam1), .m1_modifyValue(let rightParam1)):
                            return leftParam1.match(rightParam1)
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func modifyValue(_ value: Parameter<Int>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Void, (Int) -> Void> {
                        .init(mocker, kind: .m1_modifyValue(value))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func modifyValue(_ value: Parameter<Int>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_modifyValue(value))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func modifyValue(_ value: Parameter<Int>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_modifyValue(value), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_variadic_parameter() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              func printValues(_ values: Int...)
          }
          """
        } expansion: {
            """
            protocol Test {
                func printValues(_ values: Int...)
            }

            #if MOCKING
            final class MockTest: Test, MockableService {
                private let mocker = Mocker<MockTest>()
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
                func printValues(_ values: Int...) {
                    let member: Member = .m1_printValues(.value(values))
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as ([Int]) -> Void
                        return producer(values)
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_printValues(Parameter<[Int]>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_printValues(let leftParam1), .m1_printValues(let rightParam1)):
                            return leftParam1.match(rightParam1)
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func printValues(_ values: Parameter<[Int]>) -> FunctionReturnBuilder<MockTest, ReturnBuilder, Void, ([Int]) -> Void> {
                        .init(mocker, kind: .m1_printValues(values))
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func printValues(_ values: Parameter<[Int]>) -> FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_printValues(values))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func printValues(_ values: Parameter<[Int]>) -> FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_printValues(values), assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_closure_parameter() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              func execute(operation: @escaping () throws -> Void)
          }
          """
        } expansion: {
            """
            protocol Test {
                func execute(operation: @escaping () throws -> Void)
            }

            #if MOCKING
            final class MockTest: Test, MockableService {
                private let mocker = Mocker<MockTest>()
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
                func execute(operation: @escaping () throws -> Void) {
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
}
