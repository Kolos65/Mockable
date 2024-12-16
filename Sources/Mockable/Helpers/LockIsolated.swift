//
//  LockIsolated.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2024. 12. 16..
//
import Foundation

/// A generic wrapper for isolating a mutable value with a lock.
///
/// If you trust the sendability of the underlying value, consider using ``UncheckedSendable``,
/// instead.
@dynamicMemberLookup
final class LockIsolated<Value>: @unchecked Sendable {
    private var _value: Value
    private let lock = NSRecursiveLock()
    private var didSet: ((Value) -> Void)?

    /// Initializes lock-isolated state around a value.
    ///
    /// - Parameter value: A value to isolate with a lock.
    init(_ value: @autoclosure @Sendable () throws -> Value) rethrows {
        self._value = try value()
    }

    subscript<Subject>(dynamicMember keyPath: KeyPath<Value, Subject>) -> Subject {
        self.lock.sync {
            self._value[keyPath: keyPath]
        }
    }

    /// Perform an operation with isolated access to the underlying value.
    ///
    /// Useful for modifying a value in a single transaction.
    ///
    /// ```swift
    /// // Isolate an integer for concurrent read/write access:
    /// var count = LockIsolated(0)
    ///
    /// func increment() {
    ///   // Safely increment it:
    ///   self.count.withValue { $0 += 1 }
    /// }
    /// ```
    ///
    /// - Parameter operation: An operation to be performed on the the underlying value with a lock.
    /// - Returns: The result of the operation.
    func withValue<T>(
        _ operation: (inout Value) throws -> T
    ) rethrows -> T {
        try self.lock.sync {
            var value = self._value
            defer {
                self._value = value
                self.didSet?(self._value)
            }
            return try operation(&value)
        }
    }

    /// Overwrite the isolated value with a new value.
    ///
    /// ```swift
    /// // Isolate an integer for concurrent read/write access:
    /// var count = LockIsolated(0)
    ///
    /// func reset() {
    ///   // Reset it:
    ///   self.count.setValue(0)
    /// }
    /// ```
    ///
    /// > Tip: Use ``withValue(_:)`` instead of ``setValue(_:)`` if the value being set is derived
    /// > from the current value. That is, do this:
    /// >
    /// > ```swift
    /// > self.count.withValue { $0 += 1 }
    /// > ```
    /// >
    /// > ...and not this:
    /// >
    /// > ```swift
    /// > self.count.setValue(self.count + 1)
    /// > ```
    /// >
    /// > ``withValue(_:)`` isolates the entire transaction and avoids data races between reading and
    /// > writing the value.
    ///
    /// - Parameter newValue: The value to replace the current isolated value with.
    func setValue(_ newValue: @autoclosure () throws -> Value) rethrows {
        try self.lock.sync {
            self._value = try newValue()
            self.didSet?(self._value)
        }
    }
}

extension LockIsolated where Value: Sendable {
    var value: Value {
        self.lock.sync {
            self._value
        }
    }

    /// Initializes lock-isolated state around a value.
    ///
    /// - Parameter value: A value to isolate with a lock.
    /// - Parameter didSet: A callback to invoke when the value changes.
    convenience init(
        _ value: @autoclosure @Sendable () throws -> Value,
        didSet: (@Sendable (Value) -> Void)? = nil
    ) rethrows {
        try self.init(value())
        self.didSet = didSet
    }
}

extension NSRecursiveLock {
    @inlinable @discardableResult
    func sync<R>(work: () throws -> R) rethrows -> R {
        self.lock()
        defer { self.unlock() }
        return try work()
    }
}
