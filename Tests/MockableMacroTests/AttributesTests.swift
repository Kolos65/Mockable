//
//  AttributesTest.swift
//
//
//  Created by Kolos Foltanyi on 2024. 03. 17..
//

import MacroTesting
import XCTest

final class AttributesTests: MockableMacroTestCase {
    func test_attributed_requirements() {
        assertMacro {
          """
          @Mockable
          protocol AttributeTest {
              @available(iOS 15, *)
              init(name: String)

              @available(iOS 15, *)
              var prop: Int { get }

              @available(iOS 15, *)
              func test()

              @available(iOS 15, *) init(name2: String)

              @available(iOS 15, *) var prop2: Int { get }

              @available(iOS 15, *) func test2()
          }
          """
        } expansion: {
            """
            protocol AttributeTest {
                @available(iOS 15, *)
                init(name: String)

                @available(iOS 15, *)
                var prop: Int { get }

                @available(iOS 15, *)
                func test()

                @available(iOS 15, *) init(name2: String)

                @available(iOS 15, *) var prop2: Int { get }

                @available(iOS 15, *) func test2()
            }

            #if MOCKING
            final class MockAttributeTest: AttributeTest, MockableService {
                private let mocker = Mocker<MockAttributeTest>()
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
                @available(iOS 15, *)
                init(name: String) {
                }
                @available(iOS 15, *)
                init(name2: String) {
                }
                @available(iOS 15, *)
                func test() {
                    let member: Member = .m3_test
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as () -> Void
                        return producer()
                    }
                }
                @available(iOS 15, *)
                func test2() {
                    let member: Member = .m4_test2
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as () -> Void
                        return producer()
                    }
                }
                @available(iOS 15, *)
                var prop: Int {
                    get {
                        let member: Member = .m1_prop
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                @available(iOS 15, *)
                var prop2: Int {
                    get {
                        let member: Member = .m2_prop2
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_prop
                    case m2_prop2
                    case m3_test
                    case m4_test2
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_prop, .m1_prop):
                            return true
                        case (.m2_prop2, .m2_prop2):
                            return true
                        case (.m3_test, .m3_test):
                            return true
                        case (.m4_test2, .m4_test2):
                            return true
                        default:
                            return false
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockAttributeTest>
                    init(mocker: Mocker<MockAttributeTest>) {
                        self.mocker = mocker
                    }
                    @available(iOS 15, *)
                    var prop: FunctionReturnBuilder<MockAttributeTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_prop)
                    }
                    @available(iOS 15, *)
                    var prop2: FunctionReturnBuilder<MockAttributeTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m2_prop2)
                    }
                    @available(iOS 15, *)
                    func test() -> FunctionReturnBuilder<MockAttributeTest, ReturnBuilder, Void, () -> Void> {
                        .init(mocker, kind: .m3_test)
                    }
                    @available(iOS 15, *)
                    func test2() -> FunctionReturnBuilder<MockAttributeTest, ReturnBuilder, Void, () -> Void> {
                        .init(mocker, kind: .m4_test2)
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockAttributeTest>
                    init(mocker: Mocker<MockAttributeTest>) {
                        self.mocker = mocker
                    }
                    @available(iOS 15, *)
                    var prop: FunctionActionBuilder<MockAttributeTest, ActionBuilder> {
                        .init(mocker, kind: .m1_prop)
                    }
                    @available(iOS 15, *)
                    var prop2: FunctionActionBuilder<MockAttributeTest, ActionBuilder> {
                        .init(mocker, kind: .m2_prop2)
                    }
                    @available(iOS 15, *)
                    func test() -> FunctionActionBuilder<MockAttributeTest, ActionBuilder> {
                        .init(mocker, kind: .m3_test)
                    }
                    @available(iOS 15, *)
                    func test2() -> FunctionActionBuilder<MockAttributeTest, ActionBuilder> {
                        .init(mocker, kind: .m4_test2)
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockAttributeTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockAttributeTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    @available(iOS 15, *)
                    var prop: FunctionVerifyBuilder<MockAttributeTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_prop, assertion: assertion)
                    }
                    @available(iOS 15, *)
                    var prop2: FunctionVerifyBuilder<MockAttributeTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_prop2, assertion: assertion)
                    }
                    @available(iOS 15, *)
                    func test() -> FunctionVerifyBuilder<MockAttributeTest, VerifyBuilder> {
                        .init(mocker, kind: .m3_test, assertion: assertion)
                    }
                    @available(iOS 15, *)
                    func test2() -> FunctionVerifyBuilder<MockAttributeTest, VerifyBuilder> {
                        .init(mocker, kind: .m4_test2, assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }
}
