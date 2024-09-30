//
//  VerifyTests.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

import XCTest
import Foundation
import Mockable

final class VerifyTests: XCTestCase {

    // MARK: Properties

    private let mock = MockTestService<String>()

    // MARK: Overrides

    override func tearDown() {
        mock.reset()
        Matcher.reset()
    }

    // MARK: Tests

    func test_givenMockFunctionIsCalled_whenCountVerified_assertsMatchingCounts() throws {
        given(mock).getUser(for: .any).willReturn(.test1)

        _ = try mock.getUser(for: UUID())

        verify(mock)
            .getUser(for: .any).called(.once)
            .getUser(for: .any).called(.atLeastOnce)
            .getUser(for: .any).called(.less(than: 2))
            .getUser(for: .any).called(.more(than: 0))
            .getUser(for: .any).called(.moreOrEqual(to: 1))
            .getUser(for: .any).called(.lessOrEqual(to: 1))
            .getUser(for: .any).called(.from(0, to: 2))
            .getUser(for: .any).called(.exactly(1))
    }

    @MainActor
    func test_givenMockFunctionIsCalledAsyncrhonously_whenCountVerified_assertsMatchingCounts() async {
        given(mock).getUser(for: .any).willReturn(.test1)

        Task {
            try await Task.sleep(seconds: 0.5)
            _ = try mock.getUser(for: UUID())
        }

        verify(mock).getUser(for: .any).called(.never)

        await verify(mock)
            .getUser(for: .any).calledEventually(.once)
            .getUser(for: .any).calledEventually(.atLeastOnce)
            .getUser(for: .any).calledEventually(.less(than: 2))
            .getUser(for: .any).calledEventually(.more(than: 0))
            .getUser(for: .any).calledEventually(.moreOrEqual(to: 1))
            .getUser(for: .any).calledEventually(.lessOrEqual(to: 1))
            .getUser(for: .any).calledEventually(.from(0, to: 2))
            .getUser(for: .any).calledEventually(.exactly(1))
    }

    func test_givenMockPropertyAccessed_whenCountVerified_assertsGetterAndSetter() throws {
        let testName = "Name"

        given(mock).name.willReturn(testName)

        _ = mock.name
        _ = mock.name
        mock.name = testName

        verify(mock)
            .name().getCalled(2)
            .name().setCalled(.once)
    }

    @MainActor
    func test_givenMockPropertyAccessedAsynchronously_whenCountVerified_assertsGetterAndSetter() async {
        let testName = "Name"

        given(mock).name.willReturn(testName)

        Task {
            try await Task.sleep(seconds: 0.5)
            _ = mock.name
            _ = mock.name
            mock.name = testName
        }

        verify(mock)
            .name().getCalled(.never)
            .name().setCalled(.never)

        await verify(mock)
            .name().getCalledEventually(.exactly(2))
            .name().setCalledEventually(.once)
    }

    func test_givenGenericParamAndReturnFunc_whenVerifyUsed_OnlyParamIsInferred() {
        given(mock)
            .retrieveItem(item: Parameter<Int>.any)
            .willReturn(0)

        let _: Int = mock.retrieveItem(item: 0)

        verify(mock)
            .retrieveItem(item: Parameter<Int>.any)
            .called(.atLeastOnce)
    }
}
