//
//  Utils.swift
//  MockableTest
//
//  Created by Kolos Foltanyi on 2023. 11. 26..
//

import XCTest
@_exported import Mockable

/// Creates a proxy for verifying invocations of members of the given service.
///
/// Example usage of `verify(_ service:)`:
/// ```swift
/// verify(productService)
///     // assert fetch(for:) was called between 1 and 5 times
///     .fetch(for: .any).called(count: .from(1, to: 5))
///     // assert checkout(with:) was called between exactly 10 times
///     .checkout(with: .any).called(count: 10)
///     // assert url property was accessed at least 2 times
///     .url().getterCalled(count: .moreOrEqual(to: 2))
///     // assert url property was never set to nil
///     .url(newValue: .value(nil)).setterCalled(count: .never)
/// ```
/// - Parameter service: The mockable service for which invocations are verified.
/// - Returns: The service's verification builder.
public func verify<T: Mockable>(_ service: T) -> T.VerifyBuilder {
    service.verify(with: XCTAssert)
}
