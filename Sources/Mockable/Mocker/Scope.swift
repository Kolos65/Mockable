//
//  Scope.swift
//  
//
//  Created by Kolos Foltanyi on 2023. 11. 21..
//

/// An enumeration representing different scopes of the Mocker state.
///
/// Scopes can be used to only reset specific states of a mock service.
public enum Scope: CaseIterable {
    /// The scope for storing expected return values.
    case given
    /// The scope for storing actions to be performed on members.
    case when
    /// The scope for storing invocations to be verified.
    case verify
}

extension Set where Element == Scope {
    /// A convenience property representing a set containing all available scopes.
    public static var all: Self { Set(Scope.allCases) }
}
