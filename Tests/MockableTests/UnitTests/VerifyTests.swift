//
//  VerifyTests.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

import XCTest
import MockableTest

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
            .getUser(for: .any).called(count: .once)
            .getUser(for: .any).called(count: .atLeastOnce)
            .getUser(for: .any).called(count: .less(than: 2))
            .getUser(for: .any).called(count: .more(than: 0))
            .getUser(for: .any).called(count: .moreOrEqual(to: 1))
            .getUser(for: .any).called(count: .lessOrEqual(to: 1))
            .getUser(for: .any).called(count: .from(0, to: 2))
            .getUser(for: .any).called(count: .exactly(1))
    }

    func test_givenMockPropertyAccessed_whenCountVerified_assertsGetterAndSetter() throws {
        let testName = "Name"

        given(mock).name.willReturn(testName)

        _ = mock.name
        _ = mock.name
        mock.name = testName

        verify(mock)
            .name().getterCalled(count: 2)
            .name().setterCalled(count: .once)
    }

    func test_givenGenericParamAndReturnFunc_whenVerifyUsed_OnlyParamIsInferred() {
        given(mock)
            .retrieveItem(item: Parameter<Int>.any)
            .willReturn(0)

        let _: Int = mock.retrieveItem(item: 0)

        verify(mock)
            .retrieveItem(item: Parameter<Int>.any)
            .called(count: .atLeastOnce)
    }
}
