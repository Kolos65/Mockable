//
//  Publisher+Async.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2024. 04. 07..
//

#if swift(>=6)
@preconcurrency import Combine
#else
import Combine
#endif

extension Publisher where Failure == Never, Output: Sendable {
    var stream: AsyncStream<Output> {
        AsyncStream<Output> { continuation in
            let cancellable = sink {
                continuation.yield($0)
            }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}
