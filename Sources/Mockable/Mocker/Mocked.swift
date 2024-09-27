//
//  Mocked.swift
//  Mocked
//
//  Created by Kolos Foltanyi on 2024. 04. 03..
//

/// A protocol that represents auto-mocked types.
///
/// `Mocked` in combination with a `relaxedMocked` option of `MockerPolicy `can be used
/// to set an implicit return value for custom types:
///
/// ```swift
/// struct Car {
///     var name: String
///     var seats: Int
/// }
///
/// extension Car: Mocked {
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
///         let mock = MockCarService(policy: .relaxedMocked)
///         // Implictly mocked without a given registration:
///         let car = mock.getCar()
///         let cars = mock.getCars()
///     }
/// }
/// ```
public protocol Mocked {
    /// A default mock return value to use when `.relaxedMocked` policy is set.
    static var mock: Self { get }

    /// An array of mock values to use as return values when `.relaxedMocked` policy is set.
    /// Defaults to `[Self.mock]`.
    static var mocks: [Self] { get }
}

extension Mocked {
    public static var mocks: [Self] { [mock] }
}

extension Array: Mocked where Element: Mocked {
    public static var mock: Self {
        Element.mocks
    }
}

extension Optional: Mocked where Wrapped: Mocked {
    public static var mock: Self { Wrapped.mock }
}
