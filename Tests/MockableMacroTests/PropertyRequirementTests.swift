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
            final class MockTest: Test, MockService {
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
                enum Member: Matchable, CaseIdentifiable {
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
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    var computedInt: FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_computedInt)
                    }
                    var computedString: FunctionReturnBuilder<MockTest, ReturnBuilder, String, () -> String> {
                        .init(mocker, kind: .m2_computedString)
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    var computedInt: FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_computedInt)
                    }
                    var computedString: FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_computedString)
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    var computedInt: FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_computedInt, assertion: assertion)
                    }
                    var computedString: FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_computedString, assertion: assertion)
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
            final class MockTest: Test, MockService {
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
                enum Member: Matchable, CaseIdentifiable {
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
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    var mutableInt: PropertyReturnBuilder<MockTest, ReturnBuilder, Int> {
                        .init(mocker, kind: .m1_get_mutableInt)
                    }
                    var mutableString: PropertyReturnBuilder<MockTest, ReturnBuilder, String> {
                        .init(mocker, kind: .m2_get_mutableString)
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    func mutableInt(newValue: Parameter<Int> = .any) -> PropertyActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_get_mutableInt, setKind: .m1_set_mutableInt(newValue: newValue))
                    }
                    func mutableString(newValue: Parameter<String> = .any) -> PropertyActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_get_mutableString, setKind: .m2_set_mutableString(newValue: newValue))
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func mutableInt(newValue: Parameter<Int> = .any) -> PropertyVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_get_mutableInt, setKind: .m1_set_mutableInt(newValue: newValue), assertion: assertion)
                    }
                    func mutableString(newValue: Parameter<String> = .any) -> PropertyVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_get_mutableString, setKind: .m2_set_mutableString(newValue: newValue), assertion: assertion)
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
            final class MockTest: Test, MockService {
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
                enum Member: Matchable, CaseIdentifiable {
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
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    var throwingProperty: ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, Int, () throws -> Int> {
                        .init(mocker, kind: .m1_throwingProperty)
                    }
                    var asyncProperty: FunctionReturnBuilder<MockTest, ReturnBuilder, String, () -> String> {
                        .init(mocker, kind: .m2_asyncProperty)
                    }
                    var asyncThrowingProperty: ThrowingFunctionReturnBuilder<MockTest, ReturnBuilder, String, () throws -> String> {
                        .init(mocker, kind: .m3_asyncThrowingProperty)
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                    var throwingProperty: ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_throwingProperty)
                    }
                    var asyncProperty: FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m2_asyncProperty)
                    }
                    var asyncThrowingProperty: ThrowingFunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m3_asyncThrowingProperty)
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    var throwingProperty: ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_throwingProperty, assertion: assertion)
                    }
                    var asyncProperty: FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_asyncProperty, assertion: assertion)
                    }
                    var asyncThrowingProperty: ThrowingFunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m3_asyncThrowingProperty, assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }
}
