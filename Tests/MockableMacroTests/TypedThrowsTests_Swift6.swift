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

#if canImport(SwiftSyntax600)
final class TypedThrowsTests_Swift6: MockableMacroTestCase {
    func test_typed_throws_requirement() {
        assertMacro {
          """
          @Mockable
          protocol TypedErrorProtocol {
              func foo() throws(ExampleError)
              var baz: String { get throws(ExampleError) }
          }
          """
        } expansion: {
            """
            protocol TypedErrorProtocol {
                func foo() throws(ExampleError)
                var baz: String { get throws(ExampleError) }
            }

            #if MOCKING
            final class MockTypedErrorProtocol: TypedErrorProtocol, Mockable.MockableService {
                typealias Mocker = Mockable.Mocker<MockTypedErrorProtocol>
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
                func foo() throws(ExampleError) {
                    let member: Member = .m2_foo
                    try mocker.mockThrowing(member, error: ExampleError.self) { producer in
                        let producer = try cast(producer) as () throws -> Void
                        return try producer()
                    }
                }
                var baz: String {
                    get throws(ExampleError) {
                        let member: Member = .m1_baz
                        return try mocker.mockThrowing(member, error: ExampleError.self) { producer in
                            let producer = try cast(producer) as () throws -> String
                            return try producer()
                        }
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_baz
                    case m2_foo
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_baz, .m1_baz):
                            return true
                        case (.m2_foo, .m2_foo):
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
                    var baz: Mockable.ThrowingFunctionReturnBuilder<MockTypedErrorProtocol, ReturnBuilder, String, ExampleError, () throws -> String> {
                        .init(mocker, kind: .m1_baz)
                    }
                    func foo() -> Mockable.ThrowingFunctionReturnBuilder<MockTypedErrorProtocol, ReturnBuilder, Void, ExampleError, () throws -> Void> {
                        .init(mocker, kind: .m2_foo)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var baz: Mockable.ThrowingFunctionActionBuilder<MockTypedErrorProtocol, ActionBuilder> {
                        .init(mocker, kind: .m1_baz)
                    }
                    func foo() -> Mockable.ThrowingFunctionActionBuilder<MockTypedErrorProtocol, ActionBuilder> {
                        .init(mocker, kind: .m2_foo)
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var baz: Mockable.ThrowingFunctionVerifyBuilder<MockTypedErrorProtocol, VerifyBuilder> {
                        .init(mocker, kind: .m1_baz)
                    }
                    func foo() -> Mockable.ThrowingFunctionVerifyBuilder<MockTypedErrorProtocol, VerifyBuilder> {
                        .init(mocker, kind: .m2_foo)
                    }
                }
            }
            #endif
            """
        }
    }
}
#endif
