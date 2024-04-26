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
public func given<T: MockableService>(_ service: T) -> T.ReturnBuilder { service.given() }

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
public func when<T: MockableService>(_ service: T) -> T.ActionBuilder { service.when() }
