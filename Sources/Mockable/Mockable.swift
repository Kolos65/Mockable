//
//  Mockable.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 13..
//

/// A protocol defining the structure for a mockable service.
///
/// Conforming types must provide a `Member` type representing their members
/// as well as builders for specifying return values, actions, and verifications.
public protocol Mockable {

    /// A type representing the members of the mocked protocol.
    associatedtype Member: Matchable, CaseIdentifiable

    /// A builder responsible for registering return values.
    associatedtype ReturnBuilder: EffectBuilder<Self>
    /// A builder responsible for registering side-effects.
    associatedtype ActionBuilder: EffectBuilder<Self>
    /// A builder responsible for asserting member invocations.
    associatedtype VerifyBuilder: AssertionBuilder<Self>

    /// Encapsulates member return values.
    typealias Return = MemberReturn<Member>

    /// Encapsulates member side-effects.
    typealias Action = MemberAction<Member>

    /// A builder proxy for specifying return values.
    func given() -> ReturnBuilder

    /// A builder proxy for specifying actions.
    func when() -> ActionBuilder

    /// The builder proxy for verifying invocations.
    func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder
}
