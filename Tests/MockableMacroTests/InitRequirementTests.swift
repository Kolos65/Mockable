//
//  InitRequirementTests.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 23..
//

import MacroTesting
import XCTest

final class InitRequirementTests: MockableMacroTestCase {
    func test_init_requirement() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              init()
              init(name: String)
          }
          """
        } expansion: {
            """
            protocol Test {
                init()
                init(name: String)
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
                init() {
                }
                init(name: String) {
                }
                enum Member: Matchable, CaseIdentifiable {
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                }
            }
            #endif
            """
        }
    }

    func test_multiple_init_requirement() {
        assertMacro {
          """
          @Mockable
          protocol Test {
              init?() async throws
              init(name: String)
              init(name value: String, _ index: Int)
          }
          """
        } expansion: {
            """
            protocol Test {
                init?() async throws
                init(name: String)
                init(name value: String, _ index: Int)
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
                init?() async throws {
                }
                init(name: String) {
                }
                init(name value: String, _ index: Int) {
                }
                enum Member: Matchable, CaseIdentifiable {
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTest>
                    init(mocker: Mocker<MockTest>) {
                        self.mocker = mocker
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTest>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTest>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                }
            }
            #endif
            """
        }
    }
}
