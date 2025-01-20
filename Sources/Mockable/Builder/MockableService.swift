//
//  MockableService.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 13..
//

/// A protocol defining the structure for a mocked service.
///
/// Conforming types must provide a `Member` type representing their members
/// as well as builders for specifying return values, actions, and verifications.
public protocol MockableService {

    /// A type representing the members of the mocked protocol.
    associatedtype Member: Matchable, CaseIdentifiable, Sendable

    /// A builder responsible for registering return values.
    associatedtype ReturnBuilder: Builder<Self>
    /// A builder responsible for registering side-effects.
    associatedtype ActionBuilder: Builder<Self>
    /// A builder responsible for asserting member invocations.
    associatedtype VerifyBuilder: Builder<Self>

    /// Encapsulates member return values.
    typealias Return = MemberReturn<Member>

    /// Encapsulates member side-effects.
    typealias Action = MemberAction<Member>

    /// A builder proxy for specifying return values.
    var _given: ReturnBuilder { get }

    /// A builder proxy for specifying actions.
    var _when: ActionBuilder { get }

    /// The builder proxy for verifying invocations.
    var _verify: VerifyBuilder { get }
}
