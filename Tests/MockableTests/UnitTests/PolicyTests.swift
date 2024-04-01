//
//  PolicyTests.swift
//  
//
//  Created by Kolos Foltanyi on 2024. 04. 02..
//

import XCTest
import MockableTest

@Mockable
protocol PolicyService {
    func throwingVoidFunc() throws
    var throwingVoidProp: Void { get throws }
    func nonThrowingVoidFunc()
    var nonThrowingVoidProp: Void { get }
    func optionalFunc() -> String?
    var optionalProp: String? { get }
    func integerFunc() -> Int
    var integerProp: Int { get }
    func floatFunc() -> Float
    var floatProp: Float { get }
    func booleanFunc() -> Bool
    var booleanProp: Bool { get }
    func arrayFunc() -> [String]
    var arrayProp: [String] { get }
    func dictionaryFunc() -> [String: String]
    var dictionaryProp: [String: String] { get }
    func stringFunc() -> String
    var stringProp: String { get }
}

final class PolicyTests: XCTestCase {

    // MARK: Overrides

    override func tearDown() {
        Matcher.reset()
        MockerPolicy.default = .strict
    }

    // MARK: Tests

    func test_whenDefaultPolicyChanged_allCallsAreRelaxed() throws {
        let mock = MockPolicyService()
        MockerPolicy.default = .relaxed
        try testRelaxed(on: mock)
    }

    func test_whenCustomRelaxedPolicySet_allCallsAreRelaxed() throws {
        let mock = MockPolicyService(policy: .relaxed)
        try testRelaxed(on: mock)
    }

    func test_whenCustomVoidPolicySet_mockReturnsDefault() throws {
        let mock = MockPolicyService(policy: .relaxedVoid)
        try mock.throwingVoidFunc()
        try mock.throwingVoidProp
        mock.nonThrowingVoidFunc()
        mock.nonThrowingVoidProp
    }

    func test_whenCustomIntPolicySet_mockReturnsDefault() throws {
        let mock = MockPolicyService(policy: .relaxedInteger)
        XCTAssertEqual(1, mock.integerFunc())
        XCTAssertEqual(1, mock.integerProp)
        XCTAssertEqual(1, mock.floatFunc())
        XCTAssertEqual(1, mock.floatProp)
    }

    func test_whenCustomBoolPolicySet_mockReturnsDefault() throws {
        let mock = MockPolicyService(policy: .relaxedBoolean)
        XCTAssertEqual(true, mock.booleanFunc())
        XCTAssertEqual(true, mock.booleanProp)
    }

    func test_whenCustomArrayPolicySet_mockReturnsDefault() throws {
        let mock = MockPolicyService(policy: .relaxedArray)
        XCTAssertEqual([], mock.arrayFunc())
        XCTAssertEqual([], mock.arrayProp)
    }

    func test_whenCustomDictionaryPolicySet_mockReturnsDefault() throws {
        let mock = MockPolicyService(policy: .relaxedDictionary)
        XCTAssertEqual([:], mock.dictionaryFunc())
        XCTAssertEqual([:], mock.dictionaryProp)
    }

    func test_whenCustomStringPolicySet_mockReturnsDefault() throws {
        let mock = MockPolicyService(policy: .relaxedString)
        XCTAssertEqual("", mock.stringFunc())
        XCTAssertEqual("", mock.stringProp)
    }

    private func testRelaxed(on service: MockPolicyService) throws {
        try service.throwingVoidFunc()
        try service.throwingVoidProp
        service.nonThrowingVoidFunc()
        service.nonThrowingVoidProp
        XCTAssertEqual(nil, service.optionalFunc())
        XCTAssertEqual(nil, service.optionalProp)
        XCTAssertEqual(1, service.integerFunc())
        XCTAssertEqual(1, service.integerProp)
        XCTAssertEqual(1, service.floatFunc())
        XCTAssertEqual(1, service.floatProp)
        XCTAssertEqual(true, service.booleanFunc())
        XCTAssertEqual(true, service.booleanProp)
        XCTAssertEqual([], service.arrayFunc())
        XCTAssertEqual([], service.arrayProp)
        XCTAssertEqual([:], service.dictionaryFunc())
        XCTAssertEqual([:], service.dictionaryProp)
        XCTAssertEqual("", service.stringFunc())
        XCTAssertEqual("", service.stringProp)
    }
}
