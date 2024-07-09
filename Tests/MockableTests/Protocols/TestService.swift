//
//  TestService.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 24..
//

import MockableTest
import Foundation

@Mockable
protocol TestService {

    // MARK: Associated Type

    associatedtype Color
    func getFavoriteColor() -> Color

    // MARK: Properties

    var name: String { get set }
    var computed: String { get }

    // MARK: Functions

    func getUser(for id: UUID) throws -> User
    func getUsers(for ids: UUID...) -> [User]
    func setUser(user: User) async throws -> Bool
    func modify(user: User) -> Int
    func update(products: [Product]) -> Int
    func print() throws

    // MARK: Generics

    func getUserAndValue<Value>(for id: UUID, value: Value) -> (User, Value)
    func delete<T>(for value: T) -> Int
    func retrieve<V>() -> V
    func retrieveItem<T, V>(item: T) -> V
}

// swiftlint:disable all

/*
@Mockable
protocol TypedErrorProtocol {
    func theFunction() throws(ExampleError)
}*/

enum ExampleError: Error {
    case myError
}

protocol TypedErrorProtocol {
    func theFunction() throws(ExampleError)
}

final class MockTypedErrorProtocol: TypedErrorProtocol, MockableService {
    private let mocker = Mocker<MockTypedErrorProtocol>()
    @available(*, deprecated, message: "Use given(_ service:) of Mockable instead. ")
    func given() -> ReturnBuilder {
        .init(mocker: mocker)
    }
    @available(*, deprecated, message: "Use when(_ service:) of Mockable instead. ")
    func when() -> ActionBuilder {
        .init(mocker: mocker)
    }
    @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead. ")
    func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder {
        .init(mocker: mocker, assertion: assertion)
    }
    func reset(_ scopes: Set<MockerScope> = .all) {
        mocker.reset(scopes: scopes)
    }
    init(policy: MockerPolicy? = nil) {
        if let policy {
            mocker.policy = policy
        }
    }
    func theFunction() throws(ExampleError) {
        let member: Member = .m1_theFunction
        try mocker.mockThrowing(member, error: ExampleError.self) { producer in
            let producer = try cast(producer) as () throws -> Void
            return try producer()
        }
    }
    enum Member: Matchable, CaseIdentifiable {
        case m1_theFunction
        func match(_ other: Member) -> Bool {
            switch (self, other) {
            case (.m1_theFunction, .m1_theFunction):
                return true
            }
        }
    }
    struct ReturnBuilder: EffectBuilder {
        private let mocker: Mocker<MockTypedErrorProtocol>
        init(mocker: Mocker<MockTypedErrorProtocol>) {
            self.mocker = mocker
        }
        func theFunction() -> ThrowingFunctionReturnBuilder<MockTypedErrorProtocol, ReturnBuilder, Void, ExampleError, () throws -> Void> {
            .init(mocker, kind: .m1_theFunction, error: ExampleError.self)
        }
    }
    struct ActionBuilder: EffectBuilder {
        private let mocker: Mocker<MockTypedErrorProtocol>
        init(mocker: Mocker<MockTypedErrorProtocol>) {
            self.mocker = mocker
        }
        func theFunction() -> ThrowingFunctionActionBuilder<MockTypedErrorProtocol, ActionBuilder> {
            .init(mocker, kind: .m1_theFunction)
        }
    }
    struct VerifyBuilder: AssertionBuilder {
        private let mocker: Mocker<MockTypedErrorProtocol>
        private let assertion: MockableAssertion
        init(mocker: Mocker<MockTypedErrorProtocol>, assertion: @escaping MockableAssertion) {
            self.mocker = mocker
            self.assertion = assertion
        }
        func theFunction() -> ThrowingFunctionVerifyBuilder<MockTypedErrorProtocol, VerifyBuilder> {
            .init(mocker, kind: .m1_theFunction, assertion: assertion)
        }
    }
}

// swiftlint:enable all
