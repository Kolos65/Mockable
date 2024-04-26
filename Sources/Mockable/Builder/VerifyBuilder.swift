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
    associatedtype Service: MockableService

    /// Initializes a new instance of the builder with the provided `Mocker`.
    ///
    /// - Parameter mocker: The associated service's `Mocker` to provide for subsequent builders.
    init(mocker: Mocker<Service>, assertion: @escaping MockableAssertion)
}

/// Typealias for assertion block.
///
/// The XCTest implementation of assertions is only available
/// from the `MockableTest` target. Import `MockableTest` in your test target and use its:
/// * `given(_ service:)`
/// * `when(_ service:)`
/// * `verify(_ service:)`
///
/// clauses for testing.
public typealias MockableAssertion = (@autoclosure () -> Bool, @autoclosure () -> String, StaticString, UInt) -> Void
