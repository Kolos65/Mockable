//
//  DocCommentsTests.swift
//  
//
//  Created by Sagar Dagdu on 20/12/24.
//

import XCTest
import MacroTesting

final class DocCommentsTests: MockableMacroTestCase {
    func test_documentation_comments() {
        assertMacro {
           """
           /// Protocol documentation
           /// Multiple lines
           @Mockable
           protocol Test {
               var foo: Int { get }
           }
           """
        } expansion: {
            """
            /// Protocol documentation
            /// Multiple lines
            protocol Test {
                var foo: Int { get }
            }

            #if MOCKING
            /// Protocol documentation
            /// Multiple lines
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
                var foo: Int {
                    get {
                        let member: Member = .m1_foo
                        return mocker.mock(member) { producer in
                            let producer = try cast(producer) as () -> Int
                            return producer()
                        }
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
                    var foo: Mockable.FunctionReturnBuilder<MockTest, ReturnBuilder, Int, () -> Int> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                struct ActionBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var foo: Mockable.FunctionActionBuilder<MockTest, ActionBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
                struct VerifyBuilder: Mockable.Builder {
                    private let mocker: Mocker
                    init(mocker: Mocker) {
                        self.mocker = mocker
                    }
                    var foo: Mockable.FunctionVerifyBuilder<MockTest, VerifyBuilder> {
                        .init(mocker, kind: .m1_foo)
                    }
                }
            }
            #endif
            """
        }
    }
}
