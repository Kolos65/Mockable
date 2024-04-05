//
//  FunctionVerifyBuilder.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

/// A builder for verifying the number of times a mocked member was called.
///
/// This builder is typically used within the context of a higher-level builder (e.g., a `VerifyBuilder`)
/// to verify the expected number of invocations for a particular function of a mock service.
public struct FunctionVerifyBuilder<T: Mockable, ParentBuilder: AssertionBuilder<T>> {

    /// Convenient type for the associated service's Member.
    public typealias Member = T.Member

    /// The associated service's mocker.
    private var mocker: Mocker<T>

    /// The member being verified.
    private var member: Member

    /// Assertion function to use for verfications.
    private var assertion: MockableAssertion

    /// Initializes a new instance of `FunctionVerifyBuilder`.
    ///
    /// - Parameters:
    ///   - mocker: The `Mocker` instance of the associated mock service.
    ///   - kind: The member being verified.
    ///   - assertion: The assertion method to use for verfications.
    public init(_ mocker: Mocker<T>, kind member: Member, assertion: @escaping MockableAssertion) {
        self.member = member
        self.mocker = mocker
        self.assertion = assertion
    }

    /// Asserts the number of invocations of the specified member using `count`.
    ///
    /// - Parameter count: Specifies the expected invocation count.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func called(_ count: Count, file: StaticString = #file, line: UInt = #line) -> ParentBuilder {
        mocker.verify(member, count: count, assertion: assertion, file: file, line: line)
        return .init(mocker: mocker, assertion: assertion)
    }

    /// Asynchronously waits at most `timeout` interval for a successfuly assertion of
    /// `count` invocations, then fails.
    ///
    /// - Parameters:
    ///   - count: Specifies the expected invocation count.
    ///   - timeout: The maximum time it will wait for assertion to be true. Default 1 second.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func calledEventually(_ count: Count,
                                 before timeout: TimeoutDuration = .seconds(1),
                                 file: StaticString = #file,
                                 line: UInt = #line) async -> ParentBuilder {
        await mocker.verify(member, count: count, assertion: assertion, timeout: timeout, file: file, line: line)
        return .init(mocker: mocker, assertion: assertion)
    }
}
