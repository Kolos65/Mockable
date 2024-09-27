//
//  FunctionActionBuilder.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

/// A builder for specifying actions to be performed when mocking a function.
///
/// This builder is used within the context of a higher-level builder (e.g., an `ActionBuilder`)
/// to specify a desired action to perform when a particular function of a mock service is called.
public struct FunctionActionBuilder<T: MockableService, ParentBuilder: Builder<T>> {

    /// Convenient type for the associated service's Member.
    public typealias Member = T.Member

    /// The member being mocked.
    private var member: Member

    /// The associated service's mocker.
    private var mocker: Mocker<T>

    /// Initializes a new instance of `FunctionActionBuilder`.
    ///
    /// - Parameters:
    ///   - mocker: The `Mocker` instance of the associated mock service.
    ///   - kind: The member being mocked.
    public init(_ mocker: Mocker<T>, kind member: Member) {
        self.member = member
        self.mocker = mocker
    }

    /// Registers an action to be performed when the provided member is called.
    ///
    /// - Parameter action: The closure representing the action to be performed.
    /// - Returns: The parent builder, used for chaining additional specifications.
    @discardableResult
    public func perform(_ action: @escaping () -> Void) -> ParentBuilder {
        mocker.addAction(action, for: member)
        return .init(mocker: mocker)
    }
}
