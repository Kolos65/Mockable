//
//  Builder.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 21..
//

/// Used to specify members of a protocol when building
/// given or when clauses of a mock service.
public protocol Builder<Service> {

    /// The mock service associated with the Builder.
    associatedtype Service: MockableService

    /// Initializes a new instance of the builder with the provided `Mocker`.
    ///
    /// - Parameter mocker: The associated service's `Mocker` to provide for subsequent builders.
    init(mocker: Mocker<Service>)
}
