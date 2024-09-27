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
            final class MockTest: Test, Mockable.MockableService {
                typealias Mocker = Mockable.Mocker<MockTest>
                private let mocker = Mocker()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                func verify(with assertion: @escaping Mockable.MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                func reset(_ scopes: Set<Mockable.MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                init(policy: Mockable.MockerPolicy? = nil) {
                    if let policy {
                        mocker.policy = policy
                    }
                }
                init() {
                }
                init(name: String) {
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable {
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        }
                    }
                }
                struct ReturnBuilder: Mockable.EffectBuilder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                }
                struct ActionBuilder: Mockable.EffectBuilder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                }
                struct VerifyBuilder: Mockable.AssertionBuilder {
                    private let mocker: Mocker
                    private let assertion: Mockable.MockableAssertion
                    init(mocker: Mocker, assertion: @escaping Mockable.MockableAssertion) {
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
            final class MockTest: Test, Mockable.MockableService {
                typealias Mocker = Mockable.Mocker<MockTest>
                private let mocker = Mocker()
                @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
                func given() -> ReturnBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
                func when() -> ActionBuilder {
                    .init(mocker: mocker)
                }
                @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
                func verify(with assertion: @escaping Mockable.MockableAssertion) -> VerifyBuilder {
                    .init(mocker: mocker, assertion: assertion)
                }
                func reset(_ scopes: Set<Mockable.MockerScope> = .all) {
                    mocker.reset(scopes: scopes)
                }
                init(policy: Mockable.MockerPolicy? = nil) {
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
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable {
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        }
                    }
                }
                struct ReturnBuilder: Mockable.EffectBuilder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                }
                struct ActionBuilder: Mockable.EffectBuilder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                }
                struct VerifyBuilder: Mockable.AssertionBuilder {
                    private let mocker: Mocker
                    private let assertion: Mockable.MockableAssertion
                    init(mocker: Mocker, assertion: @escaping Mockable.MockableAssertion) {
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
