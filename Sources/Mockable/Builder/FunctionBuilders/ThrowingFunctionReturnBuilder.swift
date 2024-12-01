//
//  ThrowingFunctionReturnBuilder.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

/// A builder for specifying return values or producers when mocking a function.
///
/// This builder is typically used within the context of a higher-level builder (e.g., a `ReturnBuilder`)
/// to specify the desired return value or a return value producer for a throwing function of a mock service.
public struct ThrowingFunctionReturnBuilder<
    T: MockableService,
    ParentBuilder: Builder<T>,
    ReturnType,
    ErrorType: Error,
    ProduceType
> {

    /// Convenient type for the associated service's Member.
    public typealias Member = T.Member

    /// The member being mocked.
    private var member: Member

    /// The associated service's mocker.
    private var mocker: Mocker<T>

    /// Initializes a new instance of `FunctionReturnBuilder`.
    ///
    /// - Parameters:
    ///   - mocker: The `Mocker` instance of the associated mock service.
    ///   - kind: The member being mocked.
    public init(_ mocker: Mocker<T>, kind member: Member) {
        self.member = member
        self.mocker = mocker
    }

    /// Registers a return value to provide when the mocked member is called.
    ///
    /// - Parameter value: The return value to use for mocking the specified member.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func willReturn(_ value: ReturnType) -> ParentBuilder {
        mocker.addReturnValue(.return(value), for: member)
        return .init(mocker: mocker)
    }

    /// Registers an error to be thrown when the mocked member is called.
    ///
    /// - Parameter error: The error to be thrown for mocking the specified member.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func willThrow(_ error: ErrorType) -> ParentBuilder {
        mocker.addReturnValue(.throw(error), for: member)
        return .init(mocker: mocker)
    }

    /// Registers a return value producing closure to use when the mocked member is called.
    ///
    /// - Parameter producer: A closure that produces a return value or throws an error.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func willProduce(_ producer: ProduceType) -> ParentBuilder {
        mocker.addReturnValue(.produce(producer), for: member)
        return .init(mocker: mocker)
    }
}

extension ThrowingFunctionReturnBuilder where ReturnType == Void {
    /// Specifies that the void function will return normally when the mocked member is called.
    @discardableResult
    public func willReturn() -> ParentBuilder {
        mocker.addReturnValue(.return(()), for: member)
        return .init(mocker: mocker)
    }
}
