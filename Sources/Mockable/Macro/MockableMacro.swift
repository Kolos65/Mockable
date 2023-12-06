//
//  MockableMacro.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 20..
//

/// A peer macro that generates a mock implementation for the protocol it is attached to.
///
/// The generated implementation is named with a "Mock" prefix followed by the protocol name.
/// By default, the generated code is enclosed in an `#if MOCKING` condition, ensuring it is only accessible
/// in modules where the `MOCKING` compile-time condition is set.
///
/// Example usage:
///
/// ```swift
/// @Mockable
/// protocol UserService {
///     func get(id: UUID) -> User
///     func remove(id: UUID) throws
/// }
///
/// var mockUserService: MockUserService
///
/// func test() {
///     let error: UserError = .invalidId
///     let mockUser = User(id: UUID())
///
///     given(mockUserService)
///         .get(id: .any).willReturn(mockUser)
///         .remove(id: .any).willThrow(error)
///
///     try await loginService.login()
///
///     verify(mockUserService)
///         .get(id: .value(mockUser.id)).called(count: .once)
///         .remove(id: .any).called(count: .never)
/// }
/// ```
@attached(peer, names: prefixed(Mock))
public macro Mockable() = #externalMacro(module: "MockableMacro", type: "MockableMacro")
