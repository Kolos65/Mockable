//
//  FunctionReturnBuilder.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

/// A builder for specifying return values or producers when mocking a function.
///
/// This builder is typically used within the context of a higher-level builder (e.g., a `ReturnBuilder`)
/// to specify the desired return value or a return value producer for a particular function of a mock service.
public struct FunctionReturnBuilder<T: Mockable, ParentBuilder: EffectBuilder<T>, ReturnType, ProduceType> {

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
        mocker.given(member, returnValue: .return(value))
        return .init(mocker: mocker)
    }

    /// Registers a return value producing closure to use when the mocked member is called.
    ///
    /// - Parameter producer: A closure that produces a return value for the mocked member.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func willProduce(_ producer: ProduceType) -> ParentBuilder {
        mocker.given(member, returnValue: .produce(producer))
        return .init(mocker: mocker)
    }
}

extension FunctionReturnBuilder where ReturnType == () {
    @discardableResult
    public func justRuns() -> ParentBuilder {
        willReturn(())
    }
}
