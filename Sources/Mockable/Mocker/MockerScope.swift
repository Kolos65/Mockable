//
//  MockerScope.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 21..
//

/// An enumeration representing different scopes of the Mocker state.
///
/// Scopes can be used to only reset specific states of a mock service.
public enum MockerScope: CaseIterable {
    /// The scope for storing expected return values.
    case given
    /// The scope for storing actions to be performed on members.
    case when
    /// The scope for storing invocations to be verified.
    case verify
}

extension Set where Element == MockerScope {
    /// A convenience property representing a set containing all available scopes.
    public static var all: Self { Set(MockerScope.allCases) }
}
