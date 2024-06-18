//
//  PolicyTests.swift
//  
//
//  Created by Kolos Foltanyi on 2024. 04. 02..
//

import XCTest
import MockableTest

public struct Car: Equatable {
    var name: String
    var seats: Int
}

extension Car: Mockable {
    public static var mock: Car {
        Car(name: "Mock", seats: 4)
    }
}

@Mockable
private protocol PolicyService {
    func throwingVoidFunc() throws
    var throwingVoidProp: Void { get throws }
    func nonThrowingVoidFunc()
    var nonThrowingVoidProp: Void { get }
    func optionalFunc() -> String?
    var optionalProp: String? { get }
    func carFunc() -> Car
    func optionalCarFunc() -> Car?
    var carProp: Car { get }
    func carsFunc() -> [Car]
    var carsProp: [Car] { get }
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

    func test_whenOnlyOptionalPolicySet_mockReturnsNilNotMockableValue() throws {
        let mock = MockPolicyService(policy: .relaxedOptional)
        XCTAssertNil(mock.optionalCarFunc())
    }

    func test_whenCustomMockedPolicySet_mockReturnsDefault() throws {
        let mock = MockPolicyService(policy: .relaxedMockable)
        XCTAssertEqual(Car.mock, mock.carFunc())
        XCTAssertEqual(Car.mock, mock.optionalCarFunc())
        XCTAssertEqual(Car.mock, mock.carProp)
        XCTAssertEqual(Car.mocks, mock.carsFunc())
        XCTAssertEqual(Car.mocks, mock.carsProp)
    }

    private func testRelaxed(on service: MockPolicyService) throws {
        try service.throwingVoidFunc()
        try service.throwingVoidProp
        service.nonThrowingVoidFunc()
        service.nonThrowingVoidProp
        XCTAssertEqual(nil, service.optionalFunc())
        XCTAssertEqual(nil, service.optionalProp)
        XCTAssertEqual(Car.mock, service.carFunc())
        XCTAssertEqual(Car.mock, service.optionalCarFunc())
        XCTAssertEqual(Car.mock, service.carProp)
        XCTAssertEqual(Car.mocks, service.carsFunc())
        XCTAssertEqual(Car.mocks, service.carsProp)
    }
}
