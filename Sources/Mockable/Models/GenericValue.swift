//
//  GenericAttribute.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 17..
//

/// A type erased wrapper for generic parameters.
///
/// `GenericValue` encapsulates an arbitrary generic value along with a custom comparator closure.
/// The comparator is used to determine equality between two instances of `GenericValue`.
public struct GenericValue {
    /// The encapsulated value of type `Any`.
    public let value: Any

    /// The comparator closure used to determine equality between two instances of `GenericValue`.
    public let comparator: (Any, Any) -> Bool

    /// Initializes a new instance of `GenericValue`.
    ///
    /// - Parameters:
    ///   - value: The value to be encapsulated.
    ///   - comparator: The closure used to determine equality between two instances of `GenericValue`.
    public init(value: Any, comparator: @escaping (Any, Any) -> Bool) {
        self.value = value
        self.comparator = comparator
    }
}
