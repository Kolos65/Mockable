//
//  Mockable.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2024. 04. 03..
//

/// A protocol that represents auto-mocked types.
///
/// `Mockable` in combination with a `relaxedMockable` option of `MockerPolicy `can be used
/// to set an implicit return value for custom types:
///
/// ```swift
/// struct Car {
///     var name: String
///     var seats: Int
/// }
///
/// extension Car: Mockable {
///     static var mock: Car {
///         Car(name: "Mock Car", seats: 4)
///     }
///
///     // Defaults to [mock] but we can 
///     // provide a custom array of cars:
///     static var mocks: [Car] {
///         [
///             Car(name: "Mock Car 1", seats: 4),
///             Car(name: "Mock Car 2", seats: 4)
///         ]
///     }
/// }
///
/// @Mockable
/// protocol CarService {
///     func getCar() -> Car
///     func getCars() -> [Car]
/// }
///
/// func testCarService() {
///     func test() {
///         let mock = MockCarService(policy: .relaxedMockable)
///         // Implictly mocked without a given registration:
///         let car = mock.getCar()
///         let cars = mock.getCars()
///     }
/// }
/// ```
public protocol Mockable {
    /// A default mock return value to use when `.relaxedMocked` policy is set.
    static var mock: Self { get }

    /// An array of mock values to use as return values when `.relaxedMocked` policy is set.
    /// Defaults to `[Self.mock]`.
    static var mocks: [Self] { get }
}

extension Mockable {
    public static var mocks: [Self] { [mock] }
}

extension Array: Mockable where Element: Mockable {
    public static var mock: Self {
        Element.mocks
    }
}

extension Optional: Mockable where Wrapped: Mockable {
    public static var mock: Self { Wrapped.mock }
}
