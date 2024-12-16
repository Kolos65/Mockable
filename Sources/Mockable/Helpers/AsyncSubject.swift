//
//  AsyncSubject.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2024. 12. 16..
//

actor AsyncSubject<Element: Sendable>: AsyncSequence {

    typealias Failure = Never

    // MARK: Types

    struct Subscription: Equatable {
        let id: UInt64
        let continuation: AsyncStream<Element>.Continuation
        let stream: AsyncStream<Element>
        static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    }

    // MARK: Private properties

    private(set) var value: Element
    private var ids: UInt64 = 0
    private var subscriptions = [Subscription]()

    // MARK: Init

    init(_ initialValue: Element) {
        self.value = initialValue
    }

    deinit {
        for subscription in subscriptions {
            subscription.continuation.finish()
        }
    }

    func finish() {
        for subscription in subscriptions {
            subscription.continuation.finish()
        }
        subscriptions.removeAll()
    }

    nonisolated func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(parent: self)
    }

    func generateId() -> UInt64 {
        defer { ids &+= 1 }
        return ids
    }

    fileprivate func subscribe() -> (Subscription, Element) {
        let (stream, continuation) = AsyncStream<Element>.makeStream()
        let subscription = Subscription(id: generateId(), continuation: continuation, stream: stream)
        subscriptions.append(subscription)
        return (subscription, value)
    }

    fileprivate func remove(_ subscription: Subscription) {
        subscriptions.removeAll { $0 == subscription }
        subscription.continuation.finish()
    }

    func send(_ value: Element) {
        self.value = value
        for subscription in subscriptions {
            subscription.continuation.yield(value)
        }
    }

    func update(with block: (inout Element) -> Void) {
        block(&value)
        send(value)
    }

    class AsyncIterator: AsyncIteratorProtocol {
        private weak var parent: AsyncSubject?
        private var subscription: Subscription?
        private var iterator: AsyncStream<Element>.AsyncIterator?

        fileprivate init(parent: AsyncSubject) {
            self.parent = parent
        }

        deinit {
            cancelSubscription()
        }

        func next() async -> Element? {
            if iterator != nil {
                return await iterator?.next()
            } else if let parent {
                let (subscription, value) = await parent.subscribe()
                self.subscription = subscription
                iterator = subscription.stream.makeAsyncIterator()
                return value
            } else {
                return nil
            }
        }

        private func cancelSubscription() {
            guard let parent, let subscription else { return }
            Task { await parent.remove(subscription) }
        }
    }
}
