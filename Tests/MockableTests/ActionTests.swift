//
//  ActionTests.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

import XCTest
import Mockable
import MockableTest

final class ActionTests: XCTestCase {

    // MARK: Properties

    private let mock = MockTestService<String>()

    // MARK: Overrides

    override func tearDown() {
        mock.reset()
        Matcher.reset()
    }

    // MARK: Tests

    func test_givenActionRegistered_whenMockCalled_actionIsCalled() throws {
        var called = false

        given(mock).getUser(for: .any).willReturn(.test1)

        when(mock).getUser(for: .any).perform {
            called = true
        }

        _ = try mock.getUser(for: UUID())

        XCTAssertTrue(called)
    }

    func test_givenActionRegisteredForMutableProperty_whenMockCalled_relatedActionsAreCalled() {
        var getCalled = false
        var setCalled = false

        given(mock).name.willReturn("")

        when(mock)
            .name().performOnGet { getCalled = true }
            .name().performOnSet { setCalled = true }

        _ = mock.name
        mock.name = ""

        XCTAssertTrue(getCalled)
        XCTAssertTrue(setCalled)
    }

    func test_givenParameterConditionedActions_whenMockCalled_onlyCallsActionWithMatchingParameter() throws {
        var firstCalled = false
        var secondCalled = false

        let id1 = UUID()
        let id2 = UUID()

        given(mock).getUser(for: .any).willReturn(.test1)

        when(mock)
            .getUser(for: .value(id1)).perform { firstCalled = true }
            .getUser(for: .value(id2)).perform { secondCalled = true }

        _ = try mock.getUser(for: id2)

        XCTAssertFalse(firstCalled)
        XCTAssertTrue(secondCalled)
    }

    func test_givenMultipleActions_whenMockCalled_allActionsAreCalled() throws {
        var firstCalled = false
        var secondCalled = false
        var thirdCalled = false

        given(mock).getUser(for: .any).willReturn(.test1)

        when(mock)
            .getUser(for: .any).perform { firstCalled = true }
            .getUser(for: .any).perform { secondCalled = true }
            .getUser(for: .any).perform { thirdCalled = true }

        _ = try mock.getUser(for: UUID())

        XCTAssertTrue(firstCalled)
        XCTAssertTrue(secondCalled)
        XCTAssertTrue(thirdCalled)
    }

    func test_givenGenericActionsRegistered_whenMockCalled_actionWithMatchingTypeCalled() {
        var firstCalled = false
        var secondCalled = false
        var thirdCalled = false

        let id = UUID()

        given(mock)
            .delete(for: .value("id")).willReturn(1)
            .delete(for: .value(id)).willReturn(2)

        when(mock)
            .delete(for: .value("id")).perform { firstCalled = true }
            .delete(for: .value(id)).perform { secondCalled = true }
            .delete(for: .value("id")).perform { thirdCalled = true }

        _ = mock.delete(for: id)

        XCTAssertFalse(firstCalled)
        XCTAssertTrue(secondCalled)
        XCTAssertFalse(thirdCalled)
    }

    func test_givenGenericParamAndReturnFunc_whenActionUsed_onlyParamIsInfered() {
        var called = false

        given(mock)
            .retrieveItem(item: Parameter<Int>.any)
            .willReturn(0)

        when(mock)
            .retrieveItem(item: Parameter<Int>.any)
            .perform { called = true }

        let _: Int = mock.retrieveItem(item: 0)

        XCTAssertTrue(called)
    }
}
