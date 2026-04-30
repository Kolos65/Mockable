//
//  ConcurrentInvocationTests.swift
//
//
//  Created by Jalal Al-Awqati on 30.04.26.
//

import XCTest
import Mockable

@Mockable
private protocol ConcurrentInvocatioService: Sendable {
    func foo()
    func bar()
    func baz()
}

final class ConcurrentInvocationTests: XCTestCase {
    func test_concurrentInvocations_allCallCountsAreRecorded() async {
        for _ in 0..<10_000 {
            let mock = MockConcurrentInvocatioService(policy: .relaxed)

            await withTaskGroup(of: Void.self) { group in
                group.addTask { mock.foo() }
                group.addTask { mock.bar() }
                group.addTask { mock.baz() }
            }

            verify(mock)
                .foo().called(.once)
                .bar().called(.once)
                .baz().called(.once)
        }
    }
}
