//
//  Mocker.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

import Foundation
import IssueReporting

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

    /// Dictionary to store expected return values for each member.
    private var returns = LockIsolated<[Member: [Return]]>([:])
    /// Dictionary to store actions to be performed on each member.
    private var actions = LockIsolated<[Member: [Action]]>([:])
    /// Array to store invocations of members.
    private lazy var invocations = LockIsolated<[Member]>([]) { newValue in
        Task {
            #if swift(>=6.0) && !swift(>=6.1)
            self.invocationsSubject.send(newValue)
            #else
            await self.invocationsSubject.send(newValue)
            #endif
        }
    }

    /// Subject to track invocations.
    private var invocationsSubject = AsyncSubject<[Member]>([])

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
        invocations.withValue { invocations in
            invocations.append(member)
        }
    }

    /// Specifies an expected return value for a member.
    ///
    /// - Parameters:
    ///   - member: The member for which the return value is specified.
    ///   - returnValue: The expected return value.
    public func addReturnValue(_ returnValue: ReturnValue, for member: Member) {
        let given = Return(member: member, returnValue: returnValue)
        returns.withValue { returns in
            returns[member] = (returns[member] ?? []) + [given]
        }
    }

    /// Specifies an action to be performed on a member.
    ///
    /// - Parameters:
    ///   - member: The member for which the action is specified.
    ///   - action: The action to be performed.
    public func addAction(_ action: @escaping () -> Void, for member: Member) {
        let action = Action(member: member, action: action)
        actions.withValue { actions in
            actions[action.member] = (actions[action.member] ?? []) + [action]
        }
    }

    /// Verifies the number of times a member has been called.
    ///
    /// - Parameters:
    ///   - member: The member to verify.
    ///   - count: The expected number of invocations.
    public func verify(member: Member,
                       count: Count,
                       fileID: StaticString = #fileID,
                       filePath: StaticString = #filePath,
                       line: UInt = #line,
                       column: UInt = #column) {
        let matches = invocations.value.filter(member.match)
        let message = """
        Expected \(count) invocation(s) of \(member.name), but was \(matches.count).",
        """
        guard count.satisfies(matches.count) else {
            reportIssue(message, fileID: fileID, filePath: filePath, line: line, column: column)
            return
        }
    }

    /// Verifies the number of times a member should be called.
    ///
    /// - Parameters:
    ///   - member: The member to verify.
    ///   - count: The expected number of invocations.
    ///   - timeout: The maximum time it will wait for assertion to be true
    public func verify(member: Member,
                       count: Count,
                       timeout: TimeoutDuration,
                       fileID: StaticString = #fileID,
                       filePath: StaticString = #filePath,
                       line: UInt = #line,
                       column: UInt = #column) async {
        do {
            try await withTimeout(after: timeout.duration) {
                for await invocations in self.invocationsSubject {
                    let matches = invocations.filter(member.match)
                    if count.satisfies(matches.count) {
                        break
                    } else {
                        continue
                    }
                }
            }
        } catch {
            let matches = invocations.value.filter(member.match)
            let message = """
            Expected \(count) invocation(s) of \(member.name) before \(timeout.duration) s, but was \(matches.count).
            """
            guard count.satisfies(matches.count) else {
                reportIssue(message, fileID: fileID, filePath: filePath, line: line, column: column)
                return
            }
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
                returns.setValue([:])
            case .when:
                actions.setValue([:])
            case .verify:
                invocations.setValue([])
            }
        }
    }

    /// Performs actions associated with a member.
    ///
    /// - Parameter member: The member for which actions should be performed.
    public func performActions(for member: Member) {
        actions.withValue { actions in
            guard let actions = actions[member] else { return }
            let matches = actions.filter { member.match($0.member) }
            matches.forEach { $0.action() }
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

    #if swift(>=6)
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
    #endif
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

        // swiftlint:disable:next closure_body_length
        return try returns.withValue { returns in
            let matchCount = returns[member]?
                .filter { member.match($0.member) }
                .count ?? 0

            guard var candidates = returns[member], matchCount != 0 else {
                if case .value(let value) = fallback {
                    return value
                } else {
                    fatalError(notMockedMessage(member, value: V.self))
                }
            }

            for index in candidates.indices {
                let match = candidates[index]
                guard member.match(match.member) else { continue }

                let removeMatch: (inout [Member: [Return]]) -> Void = { returns in
                    guard matchCount > 1 else { return }
                    candidates.remove(at: index)
                    returns[member] = candidates
                }
                switch match.returnValue {
                case .return(let value):
                    guard let value = value as? V else { continue }
                    removeMatch(&returns)
                    return value
                case .throw(let error):
                    removeMatch(&returns)
                    throw error
                case .produce(let producer):
                    do {
                        let value = try producerResolver(producer)
                        removeMatch(&returns)
                        return value
                    } catch ProducerCastError.typeMismatch {
                        continue
                    } catch {
                        removeMatch(&returns)
                        throw error
                    }
                }
            }

            fatalError(genericNotMockedMessage(member, value: V.self))
        }
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

    #if swift(>=6)
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
    #endif
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

    #if swift(>=6)
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
    #endif
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
    ) -> V where V: Mocked {
        let relaxed = currentPolicy.contains(.relaxedMocked)
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
    ) throws -> V where V: Mocked {
        let relaxed = currentPolicy.contains(.relaxedMocked)
        return try mock(member, producerResolver, relaxed ? .value(.mock) : .none)
    }

    #if swift(>=6)
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
    ) throws(E) -> V where V: Mocked {
        do {
            let relaxed = currentPolicy.contains(.relaxedMocked)
            return try mock(member, producerResolver, relaxed ? .value(.mock) : .none)
        } catch {
            throw error as! E // swiftlint:disable:this force_cast
        }
    }
    #endif
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
    ) -> V where V: Mocked, V: ExpressibleByNilLiteral {
        // swiftlint:disable force_try
        if currentPolicy.contains(.relaxedMocked) {
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
    ) throws -> V where V: Mocked, V: ExpressibleByNilLiteral {
        if currentPolicy.contains(.relaxedMocked) {
            return try mock(member, producerResolver, .value(.mock))
        } else if currentPolicy.contains(.relaxedOptional) {
            return try mock(member, producerResolver, .value(nil))
        } else {
            return try mock(member, producerResolver, .none)
        }
    }

    #if swift(>=6)
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
    ) throws(E) -> V where V: Mocked, V: ExpressibleByNilLiteral {
        do {
            if currentPolicy.contains(.relaxedMocked) {
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
    #endif
}
