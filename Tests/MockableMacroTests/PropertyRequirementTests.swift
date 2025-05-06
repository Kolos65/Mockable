//
//  PropertyRequirementTests.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 21..
//

import MacroTesting
import XCTest

final class PropertyRequirementTests: MockableMacroTestCase {
    func test_computed_property() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              var computedInt: Int { get }
              var computedString: String! { get }
          }
          """
        } expansion: {
            """
            protocol Test {
                var computedInt: Int { get }
                var computedString: String! { get }
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
                var computedInt: Int {
                    get {
                        let member: Member = .m1_computedInt
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                var computedString: String! {
                    get {
                        let member: Member = .m2_computedString
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> String
                            return producer()
                        }
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_computedInt
                    case m2_computedString
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_computedInt, .m1_computedInt):
                            return true
                        case (.m2_computedString, .m2_computedString):
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
                    var computedInt: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_computedInt)
                    }
                    var computedString: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, String, () -> String> {
                        .init(mocker, kind: .m2_computedString)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var computedInt: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_computedInt)
                    }
                    var computedString: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_computedString)
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var computedInt: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_computedInt)
                    }
                    var computedString: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_computedString)
                    }
                }
            }
            #endif
            """
        }
    }

    func test_mutable_property() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              var mutableInt: Int { get set }
              var mutableString: String { get set }
          }
          """
        } expansion: {
            """
            protocol Test {
                var mutableInt: Int { get set }
                var mutableString: String { get set }
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
                var mutableInt: Int {
                    get {
                        let member: Member = .m1_get_mutableInt
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                    set {
                        let member: Member = .m1_set_mutableInt(newValue: .value(newValue))
                        mocker.addInvocation(for: member)
                        mocker.performActions(for: member)
                    }
                }
                var mutableString: String {
                    get {
                        let member: Member = .m2_get_mutableString
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> String
                            return producer()
                        }
                    }
                    set {
                        let member: Member = .m2_set_mutableString(newValue: .value(newValue))
                        mocker.addInvocation(for: member)
                        mocker.performActions(for: member)
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_get_mutableInt
                    case m1_set_mutableInt(newValue: Parameter<Int>)
                    case m2_get_mutableString
                    case m2_set_mutableString(newValue: Parameter<String>)
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_get_mutableInt, .m1_get_mutableInt):
                            return true
                        case (.m1_set_mutableInt(newValue: let leftNewValue), .m1_set_mutableInt(newValue: let rightNewValue)):
                            return leftNewValue.match(rightNewValue)
                        case (.m2_get_mutableString, .m2_get_mutableString):
                            return true
                        case (.m2_set_mutableString(newValue: let leftNewValue), .m2_set_mutableString(newValue: let rightNewValue)):
                            return leftNewValue.match(rightNewValue)
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
                    var mutableInt: Mockable.PropertyReturnBuilder<MockTest, ReturnBuilder, Int> {
                        .init(mocker, kind: .m1_get_mutableInt)
                    }
                    var mutableString: Mockable.PropertyReturnBuilder<MockTest, ReturnBuilder, String> {
                        .init(mocker, kind: .m2_get_mutableString)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func mutableInt(newValue: Parameter<Int> = .any) -> Mockable.PropertyActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_get_mutableInt, setKind: .m1_set_mutableInt(newValue: newValue))
                    }
                    func mutableString(newValue: Parameter<String> = .any) -> Mockable.PropertyActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_get_mutableString, setKind: .m2_set_mutableString(newValue: newValue))
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func mutableInt(newValue: Parameter<Int> = .any) -> Mockable.PropertyVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_get_mutableInt, setKind: .m1_set_mutableInt(newValue: newValue))
                    }
                    func mutableString(newValue: Parameter<String> = .any) -> Mockable.PropertyVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_get_mutableString, setKind: .m2_set_mutableString(newValue: newValue))
                    }
                }
            }
            #endif
            """
        }
    }

    func test_async_throwing_property() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              var throwingProperty: Int { get throws }
              var asyncProperty: String { get async }
              var asyncThrowingProperty: String { get async throws }
          }
          """
        } expansion: {
            """
            protocol Test {
                var throwingProperty: Int { get throws }
                var asyncProperty: String { get async }
                var asyncThrowingProperty: String { get async throws }
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
                var throwingProperty: Int {
                    get throws {
                        let member: Member = .m1_throwingProperty
                        return try mocker.mockThrowing(member) { producer in
                            let producer = try cast(producer) as () throws -> Int
                            return try producer()
                        }
                    }
                }
                var asyncProperty: String {
                    get async {
                        let member: Member = .m2_asyncProperty
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> String
                            return producer()
                        }
                    }
                }
                var asyncThrowingProperty: String {
                    get async throws {
                        let member: Member = .m3_asyncThrowingProperty
                        return try mocker.mockThrowing(member) { producer in
                            let producer = try cast(producer) as () throws -> String
                            return try producer()
                        }
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_throwingProperty
                    case m2_asyncProperty
                    case m3_asyncThrowingProperty
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_throwingProperty, .m1_throwingProperty):
                            return true
                        case (.m2_asyncProperty, .m2_asyncProperty):
                            return true
                        case (.m3_asyncThrowingProperty, .m3_asyncThrowingProperty):
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
                    var throwingProperty: Mockable.ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, Int, any Error, () throws -> Int> {
                        .init(mocker, kind: .m1_throwingProperty)
                    }
                    var asyncProperty: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, String, () -> String> {
                        .init(mocker, kind: .m2_asyncProperty)
                    }
                    var asyncThrowingProperty: Mockable.ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, String, any Error, () throws -> String> {
                        .init(mocker, kind: .m3_asyncThrowingProperty)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var throwingProperty: Mockable.ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_throwingProperty)
                    }
                    var asyncProperty: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_asyncProperty)
                    }
                    var asyncThrowingProperty: Mockable.ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m3_asyncThrowingProperty)
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var throwingProperty: Mockable.ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_throwingProperty)
                    }
                    var asyncProperty: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_asyncProperty)
                    }
                    var asyncThrowingProperty: Mockable.ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m3_asyncThrowingProperty)
                    }
                }
            }
            #endif
            """
        }
    }
}
