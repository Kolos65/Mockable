//
//  MockerPolicy.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2024. 04. 01..
//

/// A policy that controls how the library handles when no return value is found during mocking.
///
/// MockerPolicy can be used to customize mocking behavior and disable the requirement of
/// return value registration in case of built in types (like Void).
public struct MockerPolicy: OptionSet {
    /// Default policy to use when none was explicitly specified for a mock.
    ///
    /// Change this property to set the default policy to use for all mocks. Defaults to `strict`.
    public static var `default`: Self = .strict

    /// All return values must be registered, a fatal error will occur otherwise.
    public static let strict: Self = []

    /// Every literal expressible requirement will return a default value.
    public static let relaxed: Self = [
        .relaxedOptional,
        .relaxedThrowingVoid,
        .relaxedNonThrowingVoid,
        .relaxedInteger,
        .relaxedBoolean,
        .relaxedArray,
        .relaxedDictionary,
        .relaxedString
    ]

    /// Every void function will run normally without a registration
    public static let relaxedVoid: Self = [
        .relaxedNonThrowingVoid,
        .relaxedThrowingVoid
    ]

    /// Throwing Void functions will run without return value registration.
    public static let relaxedThrowingVoid = Self(rawValue: 1 << 1)

    /// Non-throwing Void functions will run without return value registration.
    public static let relaxedNonThrowingVoid = Self(rawValue: 1 << 2)

    /// Optional return values will default to nil.
    public static let relaxedOptional = Self(rawValue: 1 << 0)

    /// Integer expressible return values will default to 1.
    public static let relaxedInteger = Self(rawValue: 1 << 3)

    /// String literal expressible return values will default to an empty string.
    public static let relaxedString = Self(rawValue: 1 << 4)

    /// Integer expressible return values will default to true.
    public static let relaxedBoolean = Self(rawValue: 1 << 5)

    /// Array expressible return values will default to an empty array.
    public static let relaxedArray = Self(rawValue: 1 << 6)

    /// Dictionary expressible return values will default to an empty dictionary.
    public static let relaxedDictionary = Self(rawValue: 1 << 7)

    /// Option set raw value.
    public let rawValue: Int

    /// Creates a new option set from the given raw value.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
