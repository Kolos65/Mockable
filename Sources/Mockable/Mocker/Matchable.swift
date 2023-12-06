//
//  Matchable.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

/// A protocol for types that can be used as matchers in mock assertions.
public protocol Matchable {
    /// Determines if the receiver matches another instance of the same type according to custom criteria.
    ///
    /// - Parameter other: The instance to compare against.
    /// - Returns: `true` if the receiver matches the specified instance; otherwise, `false`.
    func match(_ other: Self) -> Bool
}
