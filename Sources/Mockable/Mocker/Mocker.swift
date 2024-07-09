//
//  Mocker.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

import Foundation
import Combine

/// A class responsible for mocking and verifying interactions with a mockable service.
///
/// The `Mocker` class keeps track of invocations, expected return values, and actions associated with
/// specific members of a mockable service.
public class Mocker<Service: MockableService>: @unchecked Sendable {

    // MARK: Public Properties

    /// The associated type representing a member of the mockable service.
    public typealias Member = Service.Member
    /// The associated type representing the return value of a member.
    public typealias Return = Service.Return
    /// The associated type representing an action to be performed on a member.
    public typealias Action = Service.Action
    /// Custom relaxation policy to use when missing return values.
    public var policy: MockerPolicy?

    // MARK: Private Properties

    /// A serial dispatch queue for thread safety when accessing mutable properties.
    private let queue = DispatchQueue(label: "com.mockable.mocker")
    /// Dictionary to store expected return values for each member.
    private var _returns = [Member: [Return]]()
    /// Dictionary to store actions to be performed on each member.
    private var _actions = [Member: [Action]]()
    /// Array to store invocations of members.
    @Published private var _invocations = [Member]()

    /// Synchornized access to return values
    private var returns: [Member: [Return]] {
        get { queue.sync { _returns } }
        set { queue.sync { _returns = newValue } }
    }

    /// Synchornized access to actions
    private var actions: [Member: [Action]] {
        get { queue.sync { _actions } }
        set { queue.sync { _actions = newValue } }
    }

    /// Synchornized access to invocations
    private var invocations: [Member] {
        get { queue.sync { _invocations } }
        set { queue.sync { _invocations = newValue } }
    }

    /// Async stream of invocations
    private var invocationsStream: AsyncStream<[Member]> {
        $_invocations.receive(on: queue).stream
    }

    /// Resolved relaxation policy to use when missing return values.
    private var currentPolicy: MockerPolicy {
        policy ?? .default
    }

    // MARK: Init

    /// Initializes a new instance of `Mocker`.
    public init(policy: MockerPolicy? = nil) {
        self.policy = policy
    }

    // MARK: Public Methods

    /// Adds an invocation for a member to the list of invocations.
    ///
    /// - Parameter member: The member for which the invocation is added.
    public func addInvocation(for member: Member) {
        invocations.append(member)
    }

    /// Specifies an expected return value for a member.
    ///
    /// - Parameters:
    ///   - member: The member for which the return value is specified.
    ///   - returnValue: The expected return value.
    public func addReturnValue(_ returnValue: ReturnValue, for member: Member) {
        let given = Return(member: member, returnValue: returnValue)
        returns[member] = (returns[member] ?? []) + [given]
    }

    /// Specifies an action to be performed on a member.
    ///
    /// - Parameters:
    ///   - member: The member for which the action is specified.
    ///   - action: The action to be performed.
    public func addAction(_ action: @escaping () -> Void, for member: Member) {
        let action = Action(member: member, action: action)
        actions[action.member] = (actions[action.member] ?? []) + [action]
    }

    /// Verifies the number of times a member has been called.
    ///
    /// - Parameters:
    ///   - member: The member to verify.
    ///   - count: The expected number of invocations.
    ///   - assertion: Assertion function to use.
    public func verify(member: Member,
                       count: Count,
                       assertion: MockableAssertion,
                       file: StaticString = #file,
                       line: UInt = #line) {
        let matches = invocations.filter(member.match)
        let message = """
        Expected \(count) invocation(s) of \(member.name), but was \(matches.count).",
        """
        assertion(count.satisfies(matches.count), message, file, line)
    }

    /// Verifies the number of times a member should be called.
    ///
    /// - Parameters:
    ///   - member: The member to verify.
    ///   - count: The expected number of invocations.
    ///   - assertion: Assertion function to use.
    ///   - timeout: The maximum time it will wait for assertion to be true
    public func verify(member: Member,
                       count: Count,
                       assertion: @escaping MockableAssertion,
                       timeout: TimeoutDuration,
                       file: StaticString = #file,
                       line: UInt = #line) async {
        do {
            try await withTimeout(after: timeout.duration) {
                for await invocations in self.invocationsStream {
                    let matches = invocations.filter(member.match)
                    if count.satisfies(matches.count) {
                        break
                    } else {
                        continue
                    }
                }
            }
        } catch {
            let matches = invocations.filter(member.match)
            let message = """
            Expected \(count) invocation(s) of \(member.name) before \(timeout.duration) s, but was \(matches.count).
            """
            assertion(count.satisfies(matches.count), message, file, line)
        }
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

    /// Performs actions associated with a member.
    ///
    /// - Parameter member: The member for which actions should be performed.
    public func performActions(for member: Member) {
        guard let actions = actions[member] else { return }
        let matches = actions.filter { member.match($0.member) }
        matches.forEach { $0.action() }
    }

    /// Mocks a member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mock<V>(_ member: Member, producerResolver: (Any) throws -> V) -> V {
        // swiftlint:disable:next force_try
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

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mockThrowing<V, E>(_ member: Member,
                                   error: E.Type,
                                   producerResolver: (Any) throws -> V) throws(E) -> V {
        do {
            return try mock(member, producerResolver, .none)
        } catch {
            throw error as! E // swiftlint:disable:this force_cast
        }
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
        No return value found for member "\(member.name)" of "\(Service.self)" \
        with parameter conditions: \(member.parameters) \
        At least one return value of type "\(V.self)" must be provided \
        matching the given parameters. Use a "given" clause to provide return values.
        """
    }

    private func genericNotMockedMessage<V>(_ member: Member, value: V.Type) -> String {
        """
        No generic return value of type \(V.self) found for member "\(member.name)" of "\(Service.self)" \
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
        // swiftlint:disable:next force_try
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

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    public func mockThrowing<E>(_ member: Member,
                                error: E.Type,
                                producerResolver: (Any) throws -> Void) throws(E) {
        do {
            let relaxed = currentPolicy.contains(.relaxedThrowingVoid)
            return try mock(member, producerResolver, relaxed ? .value(()) : .none)
        } catch {
            throw error as! E // swiftlint:disable:this force_cast
        }
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
        // swiftlint:disable:next force_try
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

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mockThrowing<V, E>(
        _ member: Member,
        error: E.Type,
        producerResolver: (Any) throws -> V
    ) throws(E) -> V where V: ExpressibleByNilLiteral {
        do {
            let relaxed = currentPolicy.contains(.relaxedThrowingVoid)
            return try mock(member, producerResolver, relaxed ? .value(nil) : .none)
        } catch {
            throw error as! E // swiftlint:disable:this force_cast
        }
    }
}

// MARK: - Mockable

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
    ) -> V where V: Mockable {
        let relaxed = currentPolicy.contains(.relaxedMockable)
        // swiftlint:disable:next force_try
        return try! mock(member, producerResolver, relaxed ? .value(.mock) : .none)
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
    ) throws -> V where V: Mockable {
        let relaxed = currentPolicy.contains(.relaxedMockable)
        return try mock(member, producerResolver, relaxed ? .value(.mock) : .none)
    }

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mockThrowing<V, E>(
        _ member: Member,
        error: E,
        producerResolver: (Any) throws -> V
    ) throws(E) -> V where V: Mockable {
        do {
            let relaxed = currentPolicy.contains(.relaxedMockable)
            return try mock(member, producerResolver, relaxed ? .value(.mock) : .none)
        } catch {
            throw error as! E // swiftlint:disable:this force_cast
        }
    }
}

// MARK: - Mockable + Optional

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
    ) -> V where V: Mockable, V: ExpressibleByNilLiteral {
        // swiftlint:disable force_try
        if currentPolicy.contains(.relaxedMockable) {
            return try! mock(member, producerResolver, .value(.mock))
        } else if currentPolicy.contains(.relaxedOptional) {
            return try! mock(member, producerResolver, .value(nil))
        } else {
            return try! mock(member, producerResolver, .none)
        }
        // swiftlint:enable force_try
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
    ) throws -> V where V: Mockable, V: ExpressibleByNilLiteral {
        if currentPolicy.contains(.relaxedMockable) {
            return try mock(member, producerResolver, .value(.mock))
        } else if currentPolicy.contains(.relaxedOptional) {
            return try mock(member, producerResolver, .value(nil))
        } else {
            return try mock(member, producerResolver, .none)
        }
    }

    /// Mocks a throwing member, performing associated actions and providing the expected return value.
    ///
    /// - Parameters:
    ///   - member: The member to mock.
    ///   - producerResolver: A closure resolving the produced value.
    /// - Returns: The expected return value.
    @discardableResult
    public func mockThrowing<V, E>(
        _ member: Member,
        error: E.Type,
        producerResolver: (Any) throws -> V
    ) throws(E) -> V where V: Mockable, V: ExpressibleByNilLiteral {
        do {
            if currentPolicy.contains(.relaxedMockable) {
                return try mock(member, producerResolver, .value(.mock))
            } else if currentPolicy.contains(.relaxedOptional) {
                return try mock(member, producerResolver, .value(nil))
            } else {
                return try mock(member, producerResolver, .none)
            }
        } catch {
            throw error as! E // swiftlint:disable:this force_cast
        }
    }
}
