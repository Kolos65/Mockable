//
//  MockerFallback.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2024. 03. 17..
//

/// Describes an optional default value to use when no stored
/// return value found during mocking.
enum MockerFallback<V> {
    /// Specifies a default value to be used when no stored return value is found.
    case value(V)

    /// Specifies that no default value should be used when no stored return value is found.
    /// This results in a fatal error. This is the default behavior.
    case none
}
