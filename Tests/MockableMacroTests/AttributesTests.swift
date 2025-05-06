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
            final class MockAttributeTest: AttributeTest, Mockable.MockableService {
                typealias Mocker = Mockable.Mocker<MockAttributeTest>
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
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
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
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    @available(iOS 15, *)
                    var prop: Mockable.FunctionReturnBuilder<MockAttributeTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_prop)
                    }
                    @available(iOS 15, *)
                    var prop2: Mockable.FunctionReturnBuilder<MockAttributeTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m2_prop2)
                    }
                    @available(iOS 15, *)
                    func test() -> Mockable.FunctionReturnBuilder<MockAttributeTest, ReturnBuilder, Void, () -> Void> {
                        .init(mocker, kind: .m3_test)
                    }
                    @available(iOS 15, *)
                    func test2() -> Mockable.FunctionReturnBuilder<MockAttributeTest, ReturnBuilder, Void, () -> Void> {
                        .init(mocker, kind: .m4_test2)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    @available(iOS 15, *)
                    var prop: Mockable.FunctionActionBuilder<MockAttributeTest, ActionBuilder> {
                        .init(mocker, kind: .m1_prop)
                    }
                    @available(iOS 15, *)
                    var prop2: Mockable.FunctionActionBuilder<MockAttributeTest, ActionBuilder> {
                        .init(mocker, kind: .m2_prop2)
                    }
                    @available(iOS 15, *)
                    func test() -> Mockable.FunctionActionBuilder<MockAttributeTest, ActionBuilder> {
                        .init(mocker, kind: .m3_test)
                    }
                    @available(iOS 15, *)
                    func test2() -> Mockable.FunctionActionBuilder<MockAttributeTest, ActionBuilder> {
                        .init(mocker, kind: .m4_test2)
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    @available(iOS 15, *)
                    var prop: Mockable.FunctionVerifyBuilder<MockAttributeTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_prop)
                    }
                    @available(iOS 15, *)
                    var prop2: Mockable.FunctionVerifyBuilder<MockAttributeTest, VerifyBuilder> {
                        .init(mocker, kind: .m2_prop2)
                    }
                    @available(iOS 15, *)
                    func test() -> Mockable.FunctionVerifyBuilder<MockAttributeTest, VerifyBuilder> {
                        .init(mocker, kind: .m3_test)
                    }
                    @available(iOS 15, *)
                    func test2() -> Mockable.FunctionVerifyBuilder<MockAttributeTest, VerifyBuilder> {
                        .init(mocker, kind: .m4_test2)
                    }
                }
            }
            #endif
            """
        }
    }
}
