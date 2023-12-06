//
//  AssertionBuilder.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 26..
//

/// Used to specify members of a protocol when building
/// verify clauses of a mock service.
public protocol AssertionBuilder<Service> {

    /// The mock service associated with the Builder.
    associatedtype Service: Mockable

    /// Initializes a new instance of the builder with the provided `Mocker`.
    ///
    /// - Parameter mocker: The associated service's `Mocker` to provide for subsequent builders.
    init(mocker: Mocker<Service>, assertion: @escaping MockableAssertion)
}
