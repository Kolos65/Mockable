#if DEBUG
#if swift(>=6.0)
@_spi(Matcher_Internal) import Mockable
import Testing

public struct MatcherTrait: TestTrait, SuiteTrait, TestScoping {

    public typealias Registration = @Sendable (Matcher) async -> Void

    private let current: TaskLocal<Matcher>
    private let matcher: @Sendable () -> Matcher
    private let registration: Registration

    public let isRecursive: Bool = true

    public init(
        current: TaskLocal<Matcher>,
        matcher: @autoclosure @escaping @Sendable () -> Matcher,
        registration: @escaping Registration
    ) {
        self.current = current
        self.matcher = matcher
        self.registration = registration
    }

    public func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {
        try await current.withValue(matcher()) {
            await registration(Matcher.current)
            try await function()
        }
    }
}

/// Provides test trait for default container
extension Trait where Self == MatcherTrait {

    /// A test trait that provides a test-isolated Matcher instance.
    ///
    /// ## Usage
    ///
    /// Add the trait to your test suite to recursively apply the scope to
    /// all tests in the suite.
    ///
    /// ```swift
    /// @Suite(.matcher { matcher in
    ///     matcher.registerMyCustomTypes()
    /// })
    /// struct MyTests {
    ///     @Test
    ///     func myTest() async {
    ///         // Your test code here
    ///         // Matcher.register calls will be isolated to this test
    ///     }
    /// }
    /// ```
    ///
    /// Or on individual tests:
    ///
    /// ```swift
    /// @Test(.matcher { matcher in
    ///     matcher.registerMyCustomTypes()
    /// })
    /// func myTest() async {
    ///     // Your test code here
    /// }
    /// ```
    public static func matcher(_ registration: @escaping MatcherTrait.Registration) -> MatcherTrait {
        // Replace the Test's scoped Matcher with a new isolated instance.
        .init(current: Matcher.$current, matcher: Matcher(), registration: registration)
    }
}
#endif
#endif
