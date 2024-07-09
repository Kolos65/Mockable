//
//  TypedThrowsTests.swift
//  
//
//  Created by Kolos Foltanyi on 08/07/2024.
//

import MacroTesting
import XCTest
import SwiftSyntax
@testable import Mockable

final class TypedThrowsTests: MockableMacroTestCase {
    func test_typed_throws_requirement() {
        assertMacro {
          """
          @Mockable
          protocol TypedErrorProtocol {
              func theFunction() throws(ExampleError)
          }
          """
        } expansion: {
            """
            protocol TypedErrorProtocol {
                func theFunction() throws(ExampleError)
            }

            #if MOCKING
            final class MockTypedErrorProtocol: TypedErrorProtocol, MockableService {
                private let mocker = Mocker<MockTypedErrorProtocol>()
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
                func theFunction() throws(ExampleError) {
                    let member: Member = .m1_theFunction
                    try mocker.mockThrowing(member, error: ExampleError.self) { producer in
                        let producer = try cast(producer) as () throws -> Void
                        return try producer()
                    }
                }
                enum Member: Matchable, CaseIdentifiable {
                    case m1_theFunction
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_theFunction, .m1_theFunction):
                            return true
                        }
                    }
                }
                struct ReturnBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTypedErrorProtocol>
                    init(mocker: Mocker<MockTypedErrorProtocol>) {
                        self.mocker = mocker
                    }
                    func theFunction() -> ThrowingFunctionReturnBuilder<MockTypedErrorProtocol, ReturnBuilder, Void, ExampleError, () throws -> Void> {
                        .init(mocker, kind: .m1_theFunction, error: ExampleError.self)
                    }
                }
                struct ActionBuilder: EffectBuilder {
                    private let mocker: Mocker<MockTypedErrorProtocol>
                    init(mocker: Mocker<MockTypedErrorProtocol>) {
                        self.mocker = mocker
                    }
                    func theFunction() -> ThrowingFunctionActionBuilder<MockTypedErrorProtocol, ActionBuilder> {
                        .init(mocker, kind: .m1_theFunction)
                    }
                }
                struct VerifyBuilder: AssertionBuilder {
                    private let mocker: Mocker<MockTypedErrorProtocol>
                    private let assertion: MockableAssertion
                    init(mocker: Mocker<MockTypedErrorProtocol>, assertion: @escaping MockableAssertion) {
                        self.mocker = mocker
                        self.assertion = assertion
                    }
                    func theFunction() -> ThrowingFunctionVerifyBuilder<MockTypedErrorProtocol, VerifyBuilder> {
                        .init(mocker, kind: .m1_theFunction, assertion: assertion)
                    }
                }
            }
            #endif
            """
        }
    }
}
