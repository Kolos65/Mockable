//
//  Parameter+Match.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 25..
//

extension Parameter {
    private func match(_ parameter: Parameter<Value>, using comparator: Matcher.Comparator<Value>?) -> Bool {
        switch (self, parameter) {
        case (.any, _): return true
        case (_, .any): return true
        case (.value(let value), .matching(let matcher)): return matcher(value)
        case (.matching(let matcher), .value(let value)): return matcher(value)
        case (.value(let value1), .value(let value2)):
            guard let comparator else {
                fatalError(noComparatorMessage)
            }
            return comparator(value1, value2)
        default: return false
        }
    }
}

// MARK: - Default

extension Parameter {
    /// Matches the current parameter with another parameter.
    ///
    /// - Parameter parameter: The parameter to match against.
    /// - Returns: `true` if the parameters match; otherwise, `false`.
    public func match(_ parameter: Parameter<Value>) -> Bool {
        match(parameter, using: Matcher.comparator(for: Value.self))
    }
}

// MARK: - Equatable

extension Parameter where Value: Equatable {
    /// Matches the current parameter with another parameter.
    ///
    /// - Parameter parameter: The parameter to match against.
    /// - Returns: `true` if the parameters match; otherwise, `false`.
    public func match(_ parameter: Parameter<Value>) -> Bool {
        match(parameter, using: Matcher.comparator(for: Value.self))
    }
}

// MARK: - Sequence

extension Parameter where Value: Sequence {
    /// Matches the current parameter with another parameter.
    ///
    /// - Parameter parameter: The parameter to match against.
    /// - Returns: `true` if the parameters match; otherwise, `false`.
    public func match(_ parameter: Parameter<Value>) -> Bool {
        match(parameter, using: Matcher.comparator(for: Value.self))
    }
}

// MARK: - Equatable Sequence

extension Parameter where Value: Equatable, Value: Sequence {
    /// Matches the current parameter with another parameter.
    ///
    /// - Parameter parameter: The parameter to match against.
    /// - Returns: `true` if the parameters match; otherwise, `false`.
    public func match(_ parameter: Parameter<Value>) -> Bool {
        match(parameter, using: Matcher.comparator(for: Value.self))
    }
}
