//
//  PropertyReturnBuilder.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

/// A builder for specifying return values or producers when mocking the getter of a mutable property.
///
/// This builder is typically used within the context of a higher-level builder (e.g., a `ReturnBuilder`)
/// to specify the desired return value or a return value producer for the getter
/// of a particular property of a mock.
public struct PropertyReturnBuilder<T: MockableService, ParentBuilder: Builder<T>, ReturnType> {

    /// Convenient type for the associated service's Member.
    public typealias Member = T.Member

    /// The member representing the getter of the property.
    var getMember: Member

    /// The associated service's mocker.
    var mocker: Mocker<T>

    /// Initializes a new instance of `PropertyReturnBuilder`.
    ///
    /// - Parameters:
    ///   - mocker: The `Mocker` instance of the associated mock service.
    ///   - getKind: The member representing the getter of the property.
    public init(_ mocker: Mocker<T>, kind getMember: Member) {
        self.getMember = getMember
        self.mocker = mocker
    }

    /// Specifies the return value when the getter of the property is called.
    ///
    /// - Parameter value: The return value to use for mocking the specified getter.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func willReturn(_ value: ReturnType) -> ParentBuilder {
        mocker.addReturnValue(.return(value), for: getMember)
        return .init(mocker: mocker)
    }

    /// Specifies the return value producing closure to use when the getter of the property is called.
    ///
    /// - Parameter producer: A closure that produces a return value for the getter.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func willProduce(_ producer: @escaping () -> ReturnType) -> ParentBuilder {
        mocker.addReturnValue(.produce(producer), for: getMember)
        return .init(mocker: mocker)
    }
}
