//
//  Parameter.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 13..
//

/// An enumeration representing different types of parameters used in mocking.
public enum Parameter<Value>: @unchecked Sendable {
    /// Matches any value.
    case any
    /// Matches a specific value.
    case value(Value)
    /// Matches a value using a custom matching closure.
    case matching((Value) -> Bool)
}

extension Parameter {
    /// Creates a type erased parameter from a value of type `T`.
    ///
    /// - Parameter value: The value to be encapsulated in a generic parameter.
    /// - Returns: A a type erased parameter containing the provided value.
    public static func generic<T>(_ value: T) -> Parameter<GenericValue> {
        Parameter<T>.value(value).eraseToGenericValue()
    }

    /// Type erases a parameter of type `Parameter<T>` to a `Parameter<GenericValue>`
    ///
    /// - Returns: A type erased parameter with the same matching behavior.
    public func eraseToGenericValue() -> Parameter<GenericValue> {
        switch self {
        case .any:
            return .any
        case .value(let value):
            let value = GenericValue(value: value) { left, right in
                guard let left = left as? Value,
                      let right = right as? Value else { return false }

                guard let comparator = Matcher.comparator(for: Value.self) else {
                    fatalError(noComparatorMessage)
                }
                return comparator(left, right)
            }
            return .value(value)
        case .matching(let matcher):
            return .matching { value in
                guard let value = value.value as? Value else { return false }
                return matcher(value)
            }
        }
    }
}

extension Parameter {
    var noComparatorMessage: String {
        """
        No comparator found for type "\(Value.self)". \
        All non-equatable types must be registered using Matcher.register(_).
        """
    }
}
