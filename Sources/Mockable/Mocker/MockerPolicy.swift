//
//  MockerPolicy.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2024. 04. 01..
//

/// A policy that controls how the library handles when no return value is found during mocking.
///
/// MockerPolicy can be used to customize mocking behavior and disable the requirement of
/// return value registration in case of certain types.
public struct MockerPolicy: OptionSet, Sendable {
    /// Default policy to use when none was explicitly specified for a mock.
    ///
    /// Change this property to set the default policy to use for all mocks. Defaults to `strict`.
    #if swift(>=6)
    nonisolated(unsafe) public static var `default`: Self = .strict
    #else
    public static var `default`: Self = .strict
    #endif

    /// All return values must be registered, a fatal error will occur otherwise.
    public static let strict: Self = []

    /// Every literal expressible requirement will return a default value.
    public static let relaxed: Self = [
        .relaxedOptional,
        .relaxedThrowingVoid,
        .relaxedNonThrowingVoid,
        .relaxedMocked
    ]

    /// Every void function will run normally without a registration
    public static let relaxedVoid: Self = [
        .relaxedNonThrowingVoid,
        .relaxedThrowingVoid
    ]

    /// Throwing Void functions will run without return value registration.
    public static let relaxedThrowingVoid = Self(rawValue: 1 << 0)

    /// Non-throwing Void functions will run without return value registration.
    public static let relaxedNonThrowingVoid = Self(rawValue: 1 << 1)

    /// Optional return values will default to nil.
    public static let relaxedOptional = Self(rawValue: 1 << 2)

    /// Types conforming to the `Mocked` protocol will default to their mock value.
    public static let relaxedMocked = Self(rawValue: 1 << 3)

    /// Option set raw value.
    public let rawValue: Int

    /// Creates a new option set from the given raw value.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
