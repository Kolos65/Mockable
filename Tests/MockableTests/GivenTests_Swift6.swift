//
//  GivenTests_Swift6.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 28/09/2024.
//

import XCTest
import Mockable
@testable import TestingShared

#if swift(>=6)
final class GivenTests_Swift6: XCTestCase {

    // MARK: Properties

    private var mock = MockTestService_Swift6()

    // MARK: Overrides

    override func tearDown() {
        mock.reset()
        Matcher.reset()
    }

    // MARK: Tests

    func test_givenTypedThrows_whenErrorSet_correctTypeThrown() {
        given(mock)
            .fetch().willThrow(.notFound)
            .fetched.willThrow(.notFound)

        do {
            try mock.fetch()
        } catch {
            XCTAssertEqual(error, UserError.notFound)
        }
        do {
            _ = try mock.fetched
        } catch {
            XCTAssertEqual(error, UserError.notFound)
        }
    }
}
#endif
