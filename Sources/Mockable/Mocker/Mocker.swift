//
//  Mocker.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

import Foundation

// swiftlint:disable force_try
/// A class responsible for mocking and verifying interactions with a mockable service.
///
/// The `Mocker` class keeps track of invocations, expected return values, and actions associated with
/// specific members of a mockable service.
public class Mocker<T: Mockable> {
    /// The associated type representing a member of the mockable service.
    public typealias Member = T.Member
    /// The associated type representing the return value of a member.
    public typealias Return = T.Return
    /// The associated type representing an action to be performed on a member.
    public typealias Action = T.Action

    /// Custom relaxation policy to use when missing return values.
    public var policy: MockerPolicy?

    /// Resolved relaxation policy to use when missing return values.
    private var currentPolicy: MockerPolicy {
        policy ?? .default
    }

    /// A serial dispatch queue for thread safety when accessing mutable properties.
    private let queue = DispatchQueue(label: "com.mockable.mocker")

    /// Dictionary to store expected return values for each member.
    private var _returns = [Member: [Return]]()
    /// Dictionary to store actions to be performed on each member.
    private var _actions = [Member: [Action]]()
    /// Array to store invocations of members.
    private var _invocations = [Member]()

    /// Synchornized access to return values
    var returns: [Member: [Return]] {
        get { queue.sync { _returns } }
        set { queue.sync { _returns = newValue } }
    }

    /// Synchornized access to actions
    var actions: [Member: [Action]] {
        get { queue.sync { _actions } }
        set { queue.sync { _actions = newValue } }
    }

    /// Synchornized access to invocations
    var invocations: [Member] {
        get { queue.sync { _invocations } }
        set { queue.sync { _invocations = newValue } }
    }

    /// Initializes a new instance of `Mocker`.
    public init(policy: MockerPolicy? = nil) {
        self.policy = policy
    }

    /// Adds an invocation for a member to the list of invocations.
    ///
    /// - Parameter member: The member for which the invocation is added.
    public func addInvocation(for member: Member) {
        invocations.append(member)
    }

    /// Performs actions associated with a member.
    ///
    /// - Parameter member: The member for which actions should be performed.
    public func performActions(for member: Member) {
        guard let actions = actions[member] else { return }
        let matches = actions.filter { member.match($0.member) }
        matches.forEach { $0.action() }
    }

    /// Specifies an expected return value for a member.
    ///
    /// - Parameters:
    ///   - member: The member for which the return value is specified.
    ///   - returnValue: The expected return value.
    public func given(_ member: Member, returnValue: ReturnValue) {
        let given = Return(member: member, returnValue: returnValue)
        returns[member] = (returns[member] ?? []) + [given]
    }

    /// Specifies an action to be performed on a member.
    ///
    /// - Parameters:
    ///   - member: The member for which the action is specified.
    ///   - action: The action to be performed.
    public func perform(_ member: Member, action: @escaping () -> Void) {
        let action = Action(member: member, action: action)
        actions[action.member] = (actions[action.member] ?? []) + [action]
    }

    /// Verifies the number of times a member has been called.
    ///
    /// - Parameters:
    ///   - member: The member to verify.
    ///   - count: The expected number of invocations.
    ///   - assertion: Assertion function to use.
    public func verify(_ member: Member,
                       count: Count,
                       assertion: MockableAssertion,
                       file: StaticString = #file,
                       line: UInt = #line) {
        let matches = invocations.filter {
            member.match($0)
        }
        assertion(
            count.satisfies(count: matches.count),
            "Expected \(count) invocation(s) of \(member.name), but was: \(matches.count).",
            file,
            line
        )
    }

    /// Resets the state of the mocker.
    ///
    /// - Parameter scopes: The set of scopes to reset (given, effect, verify).
    public func reset(scopes: Set<MockerScope>) {
        MockerScope.allCases.forEach { scope in
            guard scopes.contains(scope) else { return }
            switch scope {
            case .given:
                returns.removeAll()
            case .when:
                actions.removeAll()
            case .verify:
                invocations.removeAll()
            }
        }
    }

    /// Mocks a member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mock<V>(_ member: Member, producerResolver: (Any) throws -> V) -> V {
        return try! mock(member, producerResolver, .none)
    }

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mockThrowing<V>(_ member: Member, producerResolver: (Any) throws -> V) throws -> V {
        return try mock(member, producerResolver, .none)
    }
}

// MARK: - Helpers

extension Mocker {
    private func mock<V>(
        _ member: Member,
        _ producerResolver: (Any) throws -> V,
        _ fallback: MockerFallback<V>
    ) throws -> V {
        addInvocation(for: member)
        performActions(for: member)

        let matchCount = returns[member]?
            .filter { member.match($0.member) }
            .count ?? 0

        guard var candidates = returns[member], matchCount != 0 else {
            if case .value(let value) = fallback {
                return value
            } else {
                let message = notMockedMessage(member, value: V.self)
                fatalError(message)
            }
        }

        for index in candidates.indices {
            let match = candidates[index]
            guard member.match(match.member) else { continue }

            let removeMatch: () -> Void = {
                guard matchCount > 1 else { return }
                candidates.remove(at: index)
                self.returns[member] = candidates
            }
            switch match.returnValue {
            case .return(let value):
                guard let value = value as? V else { continue }
                removeMatch()
                return value
            case .throw(let error):
                removeMatch()
                throw error
            case .produce(let producer):
                do {
                    let value = try producerResolver(producer)
                    removeMatch()
                    return value
                } catch ProducerCastError.typeMismatch {
                    continue
                } catch {
                    removeMatch()
                    throw error
                }
            }
        }

        let message = genericNotMockedMessage(member, value: V.self)
        fatalError(message)
    }
}

// MARK: - Error Messages

extension Mocker {
    private func notMockedMessage<V>(_ member: Member, value: V.Type) -> String {
        """
        No return value found for member "\(member.name)" of "\(T.self)" \
        with parameter conditions: \(member.parameters) \
        At least one return value of type "\(V.self)" must be provided \
        matching the given parameters. Use a "given" clause to provide return values.
        """
    }

    private func genericNotMockedMessage<V>(_ member: Member, value: V.Type) -> String {
        """
        No generic return value of type \(V.self) found for member "\(member.name)" of "\(T.self)" \
        with parameter conditions: \(member.parameters) \
        At least one return value of type "\(V.self)" must be provided \
        matching the given parameters. Use a "given" clause to provide return values.
        """
    }
}

// MARK: - Void

extension Mocker {
    /// Mocks a member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    public func mock(_ member: Member, producerResolver: (Any) throws -> Void) {
        let relaxed = currentPolicy.contains(.relaxedNonThrowingVoid)
        return try! mock(member, producerResolver, relaxed ? .value(()) : .none)
    }

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    public func mockThrowing(_ member: Member, producerResolver: (Any) throws -> Void) throws {
        let relaxed = currentPolicy.contains(.relaxedThrowingVoid)
        return try mock(member, producerResolver, relaxed ? .value(()) : .none)
    }
}

// MARK: - Optional

extension Mocker {
    /// Mocks a member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mock<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) -> V where V: ExpressibleByNilLiteral {
        let relaxed = currentPolicy.contains(.relaxedOptional)
        return try! mock(member, producerResolver, relaxed ? .value(nil) : .none)
    }

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mockThrowing<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) throws -> V where V: ExpressibleByNilLiteral {
        let relaxed = currentPolicy.contains(.relaxedOptional)
        return try mock(member, producerResolver, relaxed ? .value(nil) : .none)
    }
}

// MARK: - String

extension Mocker {
    /// Mocks a member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mock<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) -> V where V: ExpressibleByStringLiteral {
        let relaxed = currentPolicy.contains(.relaxedString)
        return try! mock(member, producerResolver, relaxed ? .value("") : .none)
    }

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mockThrowing<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) throws -> V where V: ExpressibleByStringLiteral {
        let relaxed = currentPolicy.contains(.relaxedString)
        return try mock(member, producerResolver, relaxed ? .value("") : .none)
    }
}

// MARK: - Boolean

extension Mocker {
    /// Mocks a member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mock<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) -> V where V: ExpressibleByBooleanLiteral {
        let relaxed = currentPolicy.contains(.relaxedBoolean)
        return try! mock(member, producerResolver, relaxed ? .value(true) : .none)
    }

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mockThrowing<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) throws -> V where V: ExpressibleByBooleanLiteral {
        let relaxed = currentPolicy.contains(.relaxedBoolean)
        return try mock(member, producerResolver, relaxed ? .value(true) : .none)
    }
}

// MARK: - Integer

extension Mocker {
    /// Mocks a member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mock<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) -> V where V: ExpressibleByIntegerLiteral {
        let relaxed = currentPolicy.contains(.relaxedInteger)
        return try! mock(member, producerResolver, relaxed ? .value(1) : .none)
    }

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mockThrowing<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) throws -> V where V: ExpressibleByIntegerLiteral {
        let relaxed = currentPolicy.contains(.relaxedInteger)
        return try mock(member, producerResolver, relaxed ? .value(1) : .none)
    }
}

// MARK: - Array

extension Mocker {
    /// Mocks a member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mock<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) -> V where V: ExpressibleByArrayLiteral {
        let relaxed = currentPolicy.contains(.relaxedArray)
        return try! mock(member, producerResolver, relaxed ? .value([]) : .none)
    }

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mockThrowing<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) throws -> V where V: ExpressibleByArrayLiteral {
        let relaxed = currentPolicy.contains(.relaxedArray)
        return try mock(member, producerResolver, relaxed ? .value([]) : .none)
    }
}

// MARK: - Dictionary

extension Mocker {
    /// Mocks a member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mock<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) -> V where V: ExpressibleByDictionaryLiteral {
        let relaxed = currentPolicy.contains(.relaxedDictionary)
        return try! mock(member, producerResolver, relaxed ? .value([:]) : .none)
    }

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mockThrowing<V>(
        _ member: Member,
        producerResolver: (Any) throws -> V
    ) throws -> V where V: ExpressibleByDictionaryLiteral {
        let relaxed = currentPolicy.contains(.relaxedDictionary)
        return try mock(member, producerResolver, relaxed ? .value([:]) : .none)
    }
}
// swiftlint:enable force_try
