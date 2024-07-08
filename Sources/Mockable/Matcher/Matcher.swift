//
//  Matcher.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

import Foundation

/// A utility for defining matchers used in mock assertions.
public class Matcher {

    // MARK: Public Types

    /// A closure type representing a comparator function for elements of type `T`.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side element for comparison.
    ///   - rhs: The right-hand side element for comparison.
    /// - Returns: `true` if the elements match according to the comparison criteria; otherwise, `false`.
    public typealias Comparator<T> = (T, T) -> Bool

    /// A closure type representing a comparator function for elements of a sequence of type `T`.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side element for comparison.
    ///   - rhs: The right-hand side element for comparison.
    /// - Returns: `true` if the elements match according to the comparison criteria; otherwise, `false`.
    public typealias ElementComparator<T: Sequence> = (T.Element, T.Element) -> Bool

    // MARK: Private Types

    private typealias MatcherType = (mirror: Mirror, comparator: Any)

    // MARK: Private Properties

    private var matchers: [MatcherType] = []

    #if swift(>=6)
    nonisolated(unsafe) private static var `default` = Matcher()
    #else
    private static var `default` = Matcher()
    #endif

    // MARK: Init

    private init() {
        registerDefaultTypes()
        registerCustomTypes()
    }

    // MARK: - Reset

    /// Reset the default state of the matcher by removing all registered types.
    public static func reset() {
        `default` = Matcher()
    }

    // MARK: - Register

    /// Registers comparator for given type **T**.
    ///
    /// Comparator is a closure of `(T,T) -> Bool`.
    ///
    /// When several comparators for same type  are registered to common
    /// **Matcher** instance - it will resolve the most receont one.
    ///
    /// - Parameters:
    ///   - valueType: compared type
    ///   - match: comparator closure
    public static func register<T>(_ valueType: T.Type, match: @escaping Comparator<T>) {
        Self.default.register(valueType, match: match)
    }

    /// Registers comparator for type, like comparing Int.self to Int.self. These types of comparators always returns true. Register like: `Matcher.default.register(CustomType.Type.self)`
    ///
    /// - Parameter valueType: Type.Type.self
    public static func register<T>(_ valueType: T.Type.Type) {
        Self.default.register(valueType)
    }

    /// Register default comparator for Equatable types. Required for generic mocks to work.
    ///
    /// - Parameter valueType: Equatable type
    public static func register<T>(_ valueType: T.Type) where T: Equatable {
        Self.default.register(valueType)
    }

    // MARK: - Comparator

    /// Returns comparator closure for given type (if any).
    ///
    /// Comparator is a closure of `(T,T) -> Bool`.
    ///
    /// When several comparators for same type  are registered to common
    /// **Matcher** instance - it will resolve the most receont one.
    ///
    /// - Parameter valueType: compared type
    /// - Returns: comparator closure
    public static func comparator<T>(for valueType: T.Type) -> Comparator<T>? {
        Self.default.comparator(for: valueType)
    }

    /// Default Equatable comparator, compares if elements are equal.
    ///
    /// - Parameter valueType: Equatable type
    /// - Returns: comparator closure
    public static func comparator<T>(for valueType: T.Type) -> Comparator<T>? where T: Equatable {
        Self.default.comparator(for: valueType)
    }

    /// Default Equatable Sequence comparator, compares count, and then for every element equal element.
    ///
    /// - Parameter valueType: Equatable Sequence type
    /// - Returns: comparator closure
    public static func comparator<T>(for valueType: T.Type) -> Comparator<T>? where T: Equatable, T: Sequence {
        Self.default.comparator(for: valueType)
    }

    /// Default Sequence comparator, compares count, and then depending on sequence type:
    /// - for Arrays, elements will be compared element by element (verifying order as well)
    /// - other Sequences would be treated as unordered, so every element has to have matching element
    ///
    /// - Parameter valueType: Sequence type
    /// - Returns: comparator closure
    public static func comparator<T>(for valueType: T.Type) -> Comparator<T>? where T: Sequence {
        Self.default.comparator(for: valueType)
    }
}

// MARK: - Register

extension Matcher {
    private func register<T>(_ valueType: T.Type, match: @escaping Comparator<T>) {
        let mirror = Mirror(reflecting: valueType)
        matchers.append((mirror, match as Any))
    }

    private func register<T>(_ valueType: T.Type.Type) {
        register(valueType, match: { _, _ in true })
    }

    private func register<T>(_ valueType: T.Type) where T: Equatable {
        let mirror = Mirror(reflecting: valueType)
        let comparator = comparator(for: T.self)
        matchers.append((mirror, comparator as Any))
    }
}

// MARK: - Comparator

extension Matcher {
    private func comparator<T>(for valueType: T.Type) -> Comparator<T>? {
        let mirror = Mirror(reflecting: valueType)
        return comparator(by: mirror) as? (T, T) -> Bool
    }

    private func comparator<T>(for valueType: T.Type) -> Comparator<T>? where T: Equatable {
        { $0 == $1 }
    }

    private func comparator<T>(for valueType: T.Type) -> Comparator<T>? where T: Equatable, T: Sequence {
        { $0 == $1 }
    }

    private func comparator<T>(for valueType: T.Type) -> Comparator<T>? where T: Sequence {
        let mirror = Mirror(reflecting: valueType)
        if let directComparator = comparator(by: mirror) as? Comparator<T> {
            return directComparator
        }

        guard let elementComparator = comparator(for: T.Element.self) else {
            return nil
        }

        return sequenceComparator(for: valueType, elementComparator: elementComparator)
    }
}

// MARK: - Helpers

extension Matcher {
    private func comparator(by mirror: Mirror) -> Any? {
        matchers.reversed().first { matcher -> Bool in
            matcher.mirror.subjectType == mirror.subjectType
        }?.comparator
    }

    private func sequenceComparator<T: Sequence>(
        for valueType: T.Type,
        elementComparator: @escaping ElementComparator<T>
    ) -> Comparator<T>? {
        { (left: T, right: T) -> Bool in
            let left = Array(left)
            let right = Array(right)

            guard left.count == right.count else { return false }

            if valueType is [T.Element].Type {
                return self.orderedCompare(left: left, right: right, comparator: elementComparator)
            } else {
                return self.unorderedCompare(left: left, right: right, comparator: elementComparator)
            }
        }
    }

    private func orderedCompare<T>(left: [T], right: [T], comparator: Comparator<T>) -> Bool {
        left.enumerated().allSatisfy { index, element in
            comparator(element, right[index])
        }
    }

    private func unorderedCompare<T>(left: [T], right: [T], comparator: Comparator<T>) -> Bool {
        var buffer = right
        for element in left {
            let index = buffer.firstIndex { comparator(element, $0) }
            guard let index else { return false }
            buffer.remove(at: index)
        }
        return buffer.isEmpty
    }
}

// MARK: - Defaults

extension Matcher {
    private func registerCustomTypes() {
        register(GenericValue.self) { left, right -> Bool in
            left.comparator(left.value, right.value)
        }
    }

    private func registerDefaultTypes() {
        registerBasicTypes()
        registerArrays()
        registerMetaTypes()
    }

    private func registerBasicTypes() {
        register(Bool.self)
        register(String.self)
        register(Float.self)
        register(Double.self)
        register(Character.self)
        register(Int.self)
        register(Int8.self)
        register(Int16.self)
        register(Int32.self)
        register(Int64.self)
        register(UInt.self)
        register(UInt8.self)
        register(UInt16.self)
        register(UInt32.self)
        register(UInt64.self)
        register(Data.self)
        register(UUID.self)
        register(Bool?.self)
        register(String?.self)
        register(Float?.self)
        register(Double?.self)
        register(Character?.self)
        register(Int?.self)
        register(Int8?.self)
        register(Int16?.self)
        register(Int32?.self)
        register(Int64?.self)
        register(UInt?.self)
        register(UInt8?.self)
        register(UInt16?.self)
        register(UInt32?.self)
        register(UInt64?.self)
        register(Data?.self)
        register(UUID?.self)
    }

    private func registerArrays() {
        register([Bool].self)
        register([String].self)
        register([Float].self)
        register([Double].self)
        register([Character].self)
        register([Int].self)
        register([Int8].self)
        register([Int16].self)
        register([Int32].self)
        register([Int64].self)
        register([UInt].self)
        register([UInt8].self)
        register([UInt16].self)
        register([UInt32].self)
        register([UInt64].self)
        register([Data].self)
        register([UUID].self)
        register([Bool?].self)
        register([String?].self)
        register([Float?].self)
        register([Double?].self)
        register([Character?].self)
        register([Int?].self)
        register([Int8?].self)
        register([Int16?].self)
        register([Int32?].self)
        register([Int64?].self)
        register([UInt?].self)
        register([UInt8?].self)
        register([UInt16?].self)
        register([UInt32?].self)
        register([UInt64?].self)
        register([Data?].self)
        register([UUID?].self)
    }

    private func registerMetaTypes() {
        register(Any.Type.self) { _, _ in true }
        register(Bool.Type.self)
        register(String.Type.self)
        register(Float.Type.self)
        register(Double.Type.self)
        register(Character.Type.self)
        register(Int.Type.self)
        register(Int8.Type.self)
        register(Int16.Type.self)
        register(Int32.Type.self)
        register(Int64.Type.self)
        register(UInt.Type.self)
        register(UInt8.Type.self)
        register(UInt16.Type.self)
        register(UInt32.Type.self)
        register(UInt64.Type.self)
        register(Data.Type.self)
        register(Any?.Type.self) { _, _ in true }
        register(Bool?.Type.self)
        register(String?.Type.self)
        register(Float?.Type.self)
        register(Double?.Type.self)
        register(Character?.Type.self)
        register(Int?.Type.self)
        register(Int8?.Type.self)
        register(Int16?.Type.self)
        register(Int32?.Type.self)
        register(Int64?.Type.self)
        register(UInt?.Type.self)
        register(UInt8?.Type.self)
        register(UInt16?.Type.self)
        register(UInt32?.Type.self)
        register(UInt64?.Type.self)
        register(Data?.Type.self)
    }
}
