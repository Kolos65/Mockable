//
//  Utils.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2024. 03. 17..
//

/// Creates a proxy for building return values for members of the given service.
///
/// Example usage of `given(_ service:)`:
/// ```swift
/// // Throw an error for the first call and then return 'product' for every other call
/// given(productService)
///     .fetch(for: .any).willThrow(error)
///     .fetch(for: .any).willReturn(product)
///
/// // Throw an error if the id parameter ends with a 0, return a product otherwise
/// given(productService)
///     .fetch(for: .any).willProduce { id in
///         if id.uuidString.last == "0" {
///             throw error
///         } else {
///             return product
///         }
///     }
/// ```
///
/// - Parameter service: The mockable service for which return values are specified.
/// - Returns: The service's return value builder.
public func given<T: MockableService>(_ service: T) -> T.ReturnBuilder { service._given }

/// Creates a proxy for building actions for members of the given service.
///
/// Example usage of `when(_ service:)`:
/// ```swift
/// // log calls to fetch(for:)
/// when(productService).fetch(for: .any).perform {
///     print("fetch(for:) was called")
/// }
///
/// // log when url is accessed
/// when(productService).url().performOnGet {
///     print("url accessed")
/// }
///
/// // log when url is set to nil
/// when(productService).url(newValue: .value(nil)).performOnSet {
///     print("url set to nil")
/// }
/// ```
///
/// - Parameter service: The mockable service for which actions are specified.
/// - Returns: The service's action builder.
public func when<T: MockableService>(_ service: T) -> T.ActionBuilder { service._when }

/// Creates a proxy for verifying invocations of members of the given service.
///
/// Example usage of `verify(_ service:)`:
/// ```swift
/// verify(productService)
///     // assert fetch(for:) was called between 1 and 5 times
///     .fetch(for: .any).called(.from(1, to: 5))
///     // assert checkout(with:) was called between exactly 10 times
///     .checkout(with: .any).called(10)
///     // assert url property was accessed at least 2 times
///     .url().getCalled(.moreOrEqual(to: 2))
///     // assert url property was never set to nil
///     .url(newValue: .value(nil)).setCalled(.never)
/// ```
/// - Parameter service: The mockable service for which invocations are verified.
/// - Returns: The service's verification builder.
public func verify<T: MockableService>(_ service: T) -> T.VerifyBuilder { service._verify }
