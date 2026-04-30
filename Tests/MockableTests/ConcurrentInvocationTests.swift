//
//  ConcurrentInvocationTests.swift
//
//
//  Created by Jalal Al-Awqati on 30.04.26.
//

import XCTest
import Mockable

final class ConcurrentInvocationTests: XCTestCase {

    // MARK: Tests

    func test_concurrentFirstInvocations_allCallCountsAreRecorded() async {
        for _ in 0..<10000 {
            let mock = MockTestService<String>()
            given(mock).modify(user: .any).willReturn(0)
            given(mock).update(products: .any).willReturn(0)
            given(mock).getUser(for: .any).willReturn(.test1)

            let box = UncheckedBox(mock)
            await withTaskGroup(of: Void.self) { group in
                group.addTask { _ = box.value.modify(user: .test1) }
                group.addTask { _ = box.value.update(products: [.test]) }
                group.addTask { _ = try? box.value.getUser(for: UUID()) }
            }

            verify(mock)
                .modify(user: .any).called(.exactly(1))
                .update(products: .any).called(.exactly(1))
                .getUser(for: .any).called(.exactly(1))
        }
    }
}
