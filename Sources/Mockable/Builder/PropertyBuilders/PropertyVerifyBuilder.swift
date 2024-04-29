//
//  PropertyVerifyBuilder.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

/// A builder for verifying the number of times the getter and setter of a property are called.
///
/// This builder is typically used within the context of a higher-level builder (e.g., a `VerifyBuilder`)
/// to verify the expected number of invocations for the getter and setter of a particular property of a mock.
public struct PropertyVerifyBuilder<T: MockableService, ParentBuilder: AssertionBuilder<T>> {

    /// Convenient type for the associated service's Member.
    public typealias Member = T.Member

    /// The associated service's mocker.
    var mocker: Mocker<T>

    /// The member representing the getter of the property.
    var getMember: Member

    /// The member representing the setter of the property.
    var setMember: Member

    /// Assertion function to use for verfications.
    private var assertion: MockableAssertion

    /// Initializes a new instance of `PropertyVerifyBuilder`.
    ///
    /// - Parameters:
    ///   - mocker: The `Mocker` instance of the associated mock service.
    ///   - getKind: The member representing the getter of the property.
    ///   - setKind: The member representing the setter of the property.
    public init(_ mocker: Mocker<T>,
                kind getMember: Member,
                setKind setMember: Member,
                assertion: @escaping MockableAssertion) {
        self.getMember = getMember
        self.setMember = setMember
        self.mocker = mocker
        self.assertion = assertion
    }

    /// Specifies the expected number of times the getter of the property should be called.
    ///
    /// - Parameter count: The `Count` object specifying the expected invocation count.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func getCalled(_ count: Count, file: StaticString = #file, line: UInt = #line) -> ParentBuilder {
        mocker.verify(
            member: getMember,
            count: count,
            assertion: assertion,
            file: file,
            line: line
        )
        return .init(mocker: mocker, assertion: assertion)
    }

    /// Asynchronously waits at most `timeout` interval for a successfuly assertion of
    /// `count` invocations of the property's getter, then fails.
    ///
    /// - Parameters:
    ///   - count: Specifies the expected invocation count.
    ///   - timeout: The maximum time it will wait for assertion to be true. Default 1 second.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func getCalledEventually(_ count: Count,
                                    before timeout: TimeoutDuration = .seconds(1),
                                    file: StaticString = #file,
                                    line: UInt = #line) async -> ParentBuilder {
        await mocker.verify(
            member: getMember,
            count: count,
            assertion: assertion,
            timeout: timeout,
            file: file,
            line: line
        )
        return .init(mocker: mocker, assertion: assertion)
    }

    /// Specifies the expected number of times the setter of the property should be called.
    ///
    /// - Parameter count: The `Count` object specifying the expected invocation count.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func setCalled(_ count: Count, file: StaticString = #file, line: UInt = #line) -> ParentBuilder {
        mocker.verify(
            member: setMember,
            count: count,
            assertion: assertion,
            file: file,
            line: line
        )
        return .init(mocker: mocker, assertion: assertion)
    }

    /// Asynchronously waits at most `timeout` interval for a successfuly assertion of
    /// `count` invocations fot the property's setter, then fails.
    ///
    /// - Parameters:
    ///   - count: Specifies the expected invocation count.
    ///   - timeout: The maximum time it will wait for assertion to be true. Default 1 second.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func setCalledEventually(_ count: Count,
                                    before timeout: TimeoutDuration = .seconds(1),
                                    file: StaticString = #file,
                                    line: UInt = #line) async -> ParentBuilder {
        await mocker.verify(
            member: setMember,
            count: count,
            assertion: assertion,
            timeout: timeout,
            file: file,
            line: line
        )
        return .init(mocker: mocker, assertion: assertion)
    }
}
