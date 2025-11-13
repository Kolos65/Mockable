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
                func modifyValue(_ value: inout Int) {
                    let member: Member = .m1_modifyValue(.value(value))
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as (inout Int) -> Void
                        return producer(&value)
                    }
                }
                #if swift(>=6.1)
                nonisolated enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_modifyValue(Parameter<Int>)
                    nonisolated func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_modifyValue(let leftParam1), .m1_modifyValue(let rightParam1)):
                            return leftParam1.match(rightParam1)
                        }
                    }
                }
                #else
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_modifyValue(Parameter<Int>)
                    nonisolated func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_modifyValue(let leftParam1), .m1_modifyValue(let rightParam1)):
                            return leftParam1.match(rightParam1)
                        }
                    }
                }
                #endif
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func modifyValue(_ value: Parameter<Int>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Void, (inout Int) -> Void> {
                        .init(mocker, kind: .m1_modifyValue(value))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func modifyValue(_ value: Parameter<Int>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_modifyValue(value))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func modifyValue(_ value: Parameter<Int>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_modifyValue(value))
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
                func printValues(_ values: Int...) {
                    let member: Member = .m1_printValues(.value(values))
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as ([Int]) -> Void
                        return producer(values)
                    }
                }
                #if swift(>=6.1)
                nonisolated enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_printValues(Parameter<[Int]>)
                    nonisolated func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_printValues(let leftParam1), .m1_printValues(let rightParam1)):
                            return leftParam1.match(rightParam1)
                        }
                    }
                }
                #else
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_printValues(Parameter<[Int]>)
                    nonisolated func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_printValues(let leftParam1), .m1_printValues(let rightParam1)):
                            return leftParam1.match(rightParam1)
                        }
                    }
                }
                #endif
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func printValues(_ values: Parameter<[Int]>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Void, ([Int]) -> Void> {
                        .init(mocker, kind: .m1_printValues(values))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func printValues(_ values: Parameter<[Int]>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_printValues(values))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func printValues(_ values: Parameter<[Int]>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_printValues(values))
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
                func execute(operation: @escaping () throws -> Void) {
                    let member: Member = .m1_execute(operation: .value(operation))
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as (@escaping () throws -> Void) -> Void
                        return producer(operation)
                    }
                }
                #if swift(>=6.1)
                nonisolated enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_execute(operation: Parameter<() throws -> Void>)
                    nonisolated func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_execute(operation: let leftOperation), .m1_execute(operation: let rightOperation)):
                            return leftOperation.match(rightOperation)
                        }
                    }
                }
                #else
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_execute(operation: Parameter<() throws -> Void>)
                    nonisolated func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_execute(operation: let leftOperation), .m1_execute(operation: let rightOperation)):
                            return leftOperation.match(rightOperation)
                        }
                    }
                }
                #endif
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func execute(operation: Parameter<() throws -> Void>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Void, (@escaping () throws -> Void) -> Void> {
                        .init(mocker, kind: .m1_execute(operation: operation))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func execute(operation: Parameter<() throws -> Void>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_execute(operation: operation))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func execute(operation: Parameter<() throws -> Void>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_execute(operation: operation))
                    }
                }
            }
            #endif
            """
        }
    }

    func test_reserved_keyword_parameter() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              func foo(for: String)
          }
          """
        } expansion: {
            """
            protocol Test {
                func foo(for: String)
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
                func foo(for: String) {
                    let member: Member = .m1_foo(for: .value(`for`))
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as (String) -> Void
                        return producer(`for`)
                    }
                }
                #if swift(>=6.1)
                nonisolated enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo(for: Parameter<String>)
                    nonisolated func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo(for: let leftFor), .m1_foo(for: let rightFor)):
                            return leftFor.match(rightFor)
                        }
                    }
                }
                #else
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo(for: Parameter<String>)
                    nonisolated func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo(for: let leftFor), .m1_foo(for: let rightFor)):
                            return leftFor.match(rightFor)
                        }
                    }
                }
                #endif
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func foo(for: Parameter<String>) -> Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Void, (String) -> Void> {
                        .init(mocker, kind: .m1_foo(for: `for`))
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func foo(for: Parameter<String>) -> Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo(for: `for`))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    nonisolated init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    nonisolated func foo(for: Parameter<String>) -> Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo(for: `for`))
                    }
                }
            }
            #endif
            """
        }
    }
}
