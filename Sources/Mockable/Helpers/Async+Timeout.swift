//
//  Async+Timeout.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2024. 04. 04..
//

import Foundation

public struct TimeoutError: Error {}

/// Runs an async task with a timeout.
///
/// - Parameters:
///   - maxDuration: The duration in seconds `work` is allowed to run before timing out.
///   - work: The async operation to perform.
/// - Returns: Returns the result of `work` if it completed in time.
/// - Throws: Throws ``TimedOutError`` if the timeout expires before `work` completes.
///   If `work` throws an error before the timeout expires, that error is propagated to the caller.
@discardableResult
func withTimeout<Value: Sendable>(
    after maxDuration: TimeInterval,
    _ operation: @Sendable @escaping () async throws -> Value
) async throws -> Value {
    try await withThrowingTaskGroup(of: Value.self) { group in
        group.addTask(operation: operation)
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(maxDuration * 1_000_000_000))
            throw TimeoutError()
        }
        let result = try await group.next()! // swiftlint:disable:this force_unwrapping
        group.cancelAll()
        return result
    }
}
