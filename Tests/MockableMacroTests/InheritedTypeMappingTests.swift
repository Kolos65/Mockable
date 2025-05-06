//
//  InheritedTypeMappingTests.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 27/09/2024.
//

import MacroTesting
import XCTest

final class InheritedTypeMappingTests: MockableMacroTestCase {
    func test_nsobject_conformance() {
        assertMacro {
            """
            @Mockable
            protocol TestObject: NSObjectProtocol {
                func foo()
            }
            """
        } expansion: {
            """
            protocol TestObject: NSObjectProtocol {
                func foo()
            }

            #if MOCKING
            final class MockTestObject: NSObject, TestObject, Mockable.MockableService {
                typealias Mocker = Mockable.Mocker<MockTestObject>
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
                func foo() {
                    let member: Member = .m1_foo
                    mocker.mock(member) { producer in
                        let producer = try cast(producer) as () -> Void
                        return producer()
                    }
                }
                enum Member: Mockable.Matchable, Mockable.CaseIdentifiable, Swift.Sendable {
                    case m1_foo
                    func match(_ other: Member) -> Bool {
                        switch (self, other) {
                        case (.m1_foo, .m1_foo):
                            return true
                        }
                    }
                }
                struct ReturnBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo() -> Mockable.FunctionReturnBuilder<MockTestObject, ReturnBuilder, Void, () -> Void> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo() -> Mockable.FunctionActionBuilder<MockTestObject, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    func foo() -> Mockable.FunctionVerifyBuilder<MockTestObject, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
            }
            #endif
            """
        }
    }
}
