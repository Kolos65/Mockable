//
//  GivenTests.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

import XCTest
import Mockable
@testable import TestingShared

final class GivenTests: XCTestCase {

    // MARK: Properties

    private var mock = MockTestService<String>()

    // MARK: Overrides

    override func tearDown() {
        mock.reset()
        Matcher.reset()
    }

    // MARK: Tests

    func test_givenReturnValueRegistered_whenMockCalled_valueReturned() throws {
        given(mock)
            .getUser(for: .any).willReturn(.test1)
            .getUser(for: .any).willProduce { _ in .test2 }

        let user1 = try mock.getUser(for: UUID())
        let user2 = try mock.getUser(for: UUID())

        XCTAssertEqual(user1, .test1)
        XCTAssertEqual(user2, .test2)
    }

    func test_givenReturnValueRegisteredForMutableProperty_whenMockCalled_valueReturned() {
        let test1 = "name"
        let test2 = "name"

        given(mock)
            .name.willReturn(test1)
            .name.willProduce { test2 }

        let name1 = mock.name
        let name2 = mock.name

        XCTAssertEqual(name1, test1)
        XCTAssertEqual(name2, test2)
    }

    func test_givenGenericReturnValueRegistered_whenMockCalled_valueReturned() {
        let red = "red"

        given(mock).getFavoriteColor().willReturn(red)

        let color = mock.getFavoriteColor()

        XCTAssertEqual(color, red)
    }

    func test_givenParameterConditionedReturn_whenMockCalled_onlyReturnsForMatchingParameters() throws {
        let id1 = UUID()
        let id2 = UUID()

        given(mock)
            .getUser(for: .value(id1)).willReturn(User.test1)
            .getUser(for: .value(id2)).willReturn(User.test2)
            .getUsers(for: .value([id1])).willReturn([User.test1])
            .getUsers(for: .value([id2])).willReturn([User.test2])

        let testUser1 = try mock.getUser(for: id1)
        let testUser2 = try mock.getUser(for: id2)
        let testUsers1 = mock.getUsers(for: id1)
        let testUsers2 = mock.getUsers(for: id2)

        XCTAssertEqual(testUser1, User.test1)
        XCTAssertEqual(testUser2, User.test2)
        XCTAssertEqual(testUsers1, [User.test1])
        XCTAssertEqual(testUsers2, [User.test2])
    }

    func test_givenReturnWithParamComparator_whenMockCalled_valueReturnedToMatchingParameters() {
        let validIds = [UUID(), UUID()]
        let invalidIds = [UUID(), UUID()]

        let user: User = .test1
        let error: UserError = .notFound

        given(mock)
            .getUser(for: .matching { validIds.contains($0) }).willReturn(user)
            .getUser(for: .matching { invalidIds.contains($0) }).willThrow(error)

        for id in invalidIds {
            XCTAssertThrowsError(try mock.getUser(for: id))
        }
        for id in validIds {
            XCTAssertEqual(try mock.getUser(for: id), .test1)
        }
    }

    func test_givenMultipleReturn_whenMockCalled_valuesAreReturnedInOrder() throws {
        given(mock)
            .getUser(for: .any).willReturn(.test1)
            .getUser(for: .any).willReturn(.test2)
            .getUser(for: .any).willReturn(.test3)

        let testUser1 = try mock.getUser(for: UUID())
        let testUser2 = try mock.getUser(for: UUID())
        let testUser3 = try mock.getUser(for: UUID())
        let last = try mock.getUser(for: UUID())

        XCTAssertEqual(testUser1, .test1)
        XCTAssertEqual(testUser2, .test2)
        XCTAssertEqual(testUser3, .test3)
        XCTAssertEqual(last, .test3)
    }

    func test_givenGenericReturnsRegistered_whenMockCalled_valueWithMatchingTypeReturned() {
        let stringValue = "value1"
        let intValue = 1234
        let doubleValue: Double = 2.5

        given(mock)
            .getUserAndValue(for: .any, value: .any).willReturn((.test1, stringValue))
            .getUserAndValue(for: .any, value: .any).willReturn((.test2, intValue))
            .getUserAndValue(for: .any, value: .any).willReturn((.test3, doubleValue))

        let (test1, value1): (User, String) = mock.getUserAndValue(for: UUID(), value: "")
        let (test2, value2): (User, Int) = mock.getUserAndValue(for: UUID(), value: 0)
        let (test3, value3): (User, Double) = mock.getUserAndValue(for: UUID(), value: 0.5)

        XCTAssertEqual(test1, .test1)
        XCTAssertEqual(value1, stringValue)
        XCTAssertEqual(test2, .test2)
        XCTAssertEqual(value2, intValue)
        XCTAssertEqual(test3, .test3)
        XCTAssertEqual(value3, doubleValue)
    }

    func test_givenVoidProducerRegistered_whenMockCalled_producerUsedToProduceResult() {
        given(mock).print().willProduce { throw UserError.notFound }

        XCTAssertThrowsError(try mock.print())
    }

    func test_givenGenericProducers_whenMockCalled_matchingProducerIsUsedToReturnValue() {
        let stringValue = "value1"
        let intValue = 1234

        given(mock)
            .retrieve().willProduce { stringValue }
            .retrieve().willProduce { intValue }

        let test: Int = mock.retrieve()

        XCTAssertEqual(test, intValue)
    }

    func test_givenError_whenMockCalled_errorIsThrown() async {
        given(mock).setUser(user: .any).willThrow(UserError.notFound)

        do {
            _ = try await mock.setUser(user: .test1)
        } catch let error as UserError {
            XCTAssertEqual(error, UserError.notFound)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }

    func test_givenThrowingProducer_whenMockCalled_errorIsThrown() async {
        given(mock)
            .setUser(user: .any).willProduce { _ in throw UserError.notFound }

        do {
            _ = try await mock.setUser(user: .test1)
        } catch let error as UserError {
            XCTAssertEqual(error, UserError.notFound)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }

    func test_givenMultipleGivenClauses_whenMockCalled_givensAreUsedInOrder() {
        given(mock)
            .getUser(for: .any).willReturn(.test1)
            .getUser(for: .any).willThrow(UserError.notFound)
            .getUser(for: .any).willProduce { _ in .test2 }
            .getUser(for: .any).willProduce { _ in throw UserError.notFound }

        XCTAssertEqual(try mock.getUser(for: UUID()), .test1)
        XCTAssertThrowsError(try mock.getUser(for: UUID()))
        XCTAssertEqual(try mock.getUser(for: UUID()), .test2)
        XCTAssertThrowsError(try mock.getUser(for: UUID()))
    }

    func test_givenEquatableParameterWithCondition_whenMockCalled_canMatchWithDefaultMatcher() {
        let user1: User = .test1
        let user2: User = .test2
        let user3: User = .test3

        given(mock)
            .modify(user: .value(user1)).willReturn(1)
            .modify(user: .matching { (user: User) in user == user2 }).willReturn(2)
            .modify(user: Parameter<User>.any).willReturn(3)

        XCTAssertEqual(mock.modify(user: user1), 1)
        XCTAssertEqual(mock.modify(user: user2), 2)
        XCTAssertEqual(mock.modify(user: user3), 3)
    }

    func test_givenGenericParameterWithCondition_whenMockCalled_canMatchWithRegistered() {
        let user1: User = .test1
        let user2: User = .test2
        let user3: User = .test3

        Matcher.register(User.self)

        given(mock)
            .delete(for: .value(user1)).willReturn(1)
            .delete(for: .matching { (user: User) in user == user2 }).willReturn(2)
            .delete(for: Parameter<User>.any).willReturn(3)

        XCTAssertEqual(mock.delete(for: user1), 1)
        XCTAssertEqual(mock.delete(for: user2), 2)
        XCTAssertEqual(mock.delete(for: user3), 3)
    }

    func test_givenNonEquatableParameterWithCondition_whenCalled_canMatchWithRegisteredMatcher() {
        Matcher.register(Product.self, match: { $0.name == $1.name })

        given(mock)
            .update(products: .value([.test])).willReturn(1)
            .update(products: .matching { $0.allSatisfy { $0.name == Product.test.name } }).willReturn(2)
            .update(products: .any).willReturn(3)

        XCTAssertEqual(mock.update(products: [.test]), 1)
        XCTAssertEqual(mock.update(products: [.test]), 2)
        XCTAssertEqual(mock.update(products: [.test]), 3)
    }

    func test_givenGenericParamAndReturnFunc_whenValueGiven_genericsAreInferred() {
        given(mock)
            .retrieveItem(item: Parameter<Int>.any)
            .willReturn(1234)

        let result: Int = mock.retrieveItem(item: 0)

        XCTAssertEqual(result, 1234)
    }

    func test_givenEscapingClosureParam_whenWillProduceCalled_closureCanBeSaved() throws {
        var storedCompletion: ((Product) -> Void)?

        given(mock)
            .download(completion: .any)
            .willProduce { completion in
                storedCompletion = completion
            }

        mock.download { _ in }

        XCTAssertNotNil(storedCompletion)
    }

    func test_givenInoutParam_whenWillProduceUsed_mutationWorks() {
        given(mock)
            .change(user: .any)
            .willProduce { param in
                param.age = 100
            }
        var user: User = .init(name: "test", age: 0)
        mock.change(user: &user)

        XCTAssertEqual(user.age, 100)
    }

    func test_givenResult_willEmitSuccess() throws {
        let expected = User.test1
        let result: Result<User, any Error> = .success(expected)

        given(mock)
            .getUser(for: .any)
            .willHandleResult(result)

        let actual = try mock.getUser(for: .init())

        XCTAssertEqual(actual, expected)
    }

    func test_givenResult_willThrow() throws {
        let expected = UserError.notFound
        let result: Result<User, any Error> = .failure(expected)

        given(mock)
            .getUser(for: .any)
            .willHandleResult(result)

        XCTAssertThrowsError(try mock.getUser(for: .init()))
    }

    @MainActor
    func test_givenConcurrentGivens_whenCalled_synchronizedCorrectly() async throws {
        // Register return values concurrently
        await withTaskGroup(of: Void.self) { @MainActor group in
            for _ in (0..<50) {
                group.addTask { @MainActor in given(self.mock).getUser(for: .any).willReturn(.test1) }
                group.addTask { @MainActor in given(self.mock).getUser(for: .any).willReturn(.test2) }
            }
            await group.waitForAll()
        }

        // Concurrent calls
        await withTaskGroup(of: Void.self) { @MainActor group in
            let id = UUID()
            for _ in (0..<50) {
                group.addTask { @MainActor in _ = try? self.mock.getUser(for: id) }
                group.addTask { @MainActor in _ = try? self.mock.getUser(for: id) }
            }
            await group.waitForAll()
        }

        // Concurrent verifications
        await withTaskGroup(of: Void.self) { @MainActor group in
            let verify = verify(self.mock)
            for index in (0..<100) {
                group.addTask { await verify.getUser(for: .any).calledEventually(.moreOrEqual(to: index)) }
                group.addTask { verify.getUser(for: .any).called(100) }
            }
            await group.waitForAll()
        }
    }
}
