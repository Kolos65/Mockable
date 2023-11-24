//
//  Count.swift
//  
//
//  Created by Kolos Foltanyi on 2023. 11. 13..
//

/// An enumeration representing different counting conditions for verifying invocations.
///
/// - `atLeastOnce`: The member should be called at least once.
/// - `once`: The member should be called exactly once.
/// - `exactly(Int)`: The member should be called a specific number of times.
/// - `from(Int, to: Int)`: The member should be called within a specific range of times.
/// - `less(than: Int)`: The member should be called less than a specific number of times.
/// - `lessOrEqual(to: Int)`: The member should be called less than or equal to a specific number of times.
/// - `more(than: Int)`: The member should be called more than a specific number of times.
/// - `moreOrEqual(to: Int)`: The member should be called more than or equal to a specific number of times.
/// - `never`: The member should never be called.
public enum Count: ExpressibleByIntegerLiteral {
    /// The associated type for the integer literal.
    public typealias IntegerLiteralType = Int

    /// Initializes a new instance of `Count` using an integer literal.
    ///
    /// - Parameter value: The integer literal value.
    public init(integerLiteral value: IntegerLiteralType) {
        self = .exactly(value)
    }

    case atLeastOnce
    case once
    case exactly(Int)
    case from(Int, to: Int)
    case less(than: Int)
    case lessOrEqual(to: Int)
    case more(than: Int)
    case moreOrEqual(to: Int)
    case never

    /// Checks if the given count satisfies the specified condition.
    ///
    /// - Parameter count: The actual count to be compared.
    /// - Returns: `true` if the condition is satisfied; otherwise, `false`.
    func satisfies(count: Int) -> Bool {
        switch self {
        case .atLeastOnce: return count >= 1
        case .once: return count == 1
        case .exactly(let times): return count == times
        case .from(let from, let to): return count >= from && count <= to
        case .less(let than): return count < than
        case .lessOrEqual(let to): return count <= to
        case .more(let than): return count > than
        case .moreOrEqual(let to): return count >= to
        case .never: return count == 0
        }
    }
}

extension Count: CustomStringConvertible {
    public var description: String {
        switch self {
        case .atLeastOnce:
            return "at least 1"
        case .once:
            return "exactly one"
        case .exactly(let value):
            return "exactly \(value)"
        case .from(let lowerBound, let upperBound):
            return "from \(lowerBound) to \(upperBound)"
        case .less(let value):
            return "less than \(value)"
        case .lessOrEqual(let value):
            return "less than or equal to \(value)"
        case .more(let value):
            return "more than \(value)"
        case .moreOrEqual(let value):
            return "more than or equal to \(value)"
        case .never:
            return "none"
        }
    }
}
