//
//  Publisher+Async.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2024. 04. 07..
//

import Combine

extension Publisher where Failure == Never {
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
