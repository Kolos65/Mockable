//
//  PropertyActionBuilder.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

/// A builder for specifying actions to be performed when mocking the getter and setter of a property.
///
/// This builder is typically used within the context of a higher-level builder (e.g., an `ActionBuilder`)
/// to specify the behavior of the getter and setter of a particular property of a mock.
public struct PropertyActionBuilder<T: MockableService, ParentBuilder: Builder<T>> {

    /// Convenient type for the associated service's Member.
    public typealias Member = T.Member

    /// The member representing the getter of the property.
    var getMember: Member

    /// The member representing the setter of the property.
    var setMember: Member

    /// The associated service's mocker.
    var mocker: Mocker<T>

    /// Initializes a new instance of `PropertyActionBuilder`.
    ///
    /// - Parameters:
    ///   - mocker: The `Mocker` instance of the associated mock service.
    ///   - getKind: The member representing the getter of the property.
    ///   - setKind: The member representing the setter of the property.
    public init(_ mocker: Mocker<T>, kind getMember: Member, setKind setMember: Member) {
        self.getMember = getMember
        self.setMember = setMember
        self.mocker = mocker
    }

    /// Specifies the action to be performed when the getter of the property is called.
    ///
    /// - Parameter action: The closure representing the action to be performed.
    /// - Returns: The parent builder, typically used for chaining additional specifications.
    @discardableResult
    public func performOnGet(_ action: @escaping () -> Void) -> ParentBuilder {
        mocker.addAction(action, for: getMember)
        return .init(mocker: mocker)
    }

    /// Specifies the action to be performed when the setter of the property is called.
    ///
    /// - Parameter action: The closure representing the action to be performed.
    /// - Returns: The parent builder, typically used for chaining additional specifications.
    @discardableResult
    public func performOnSet(_ action: @escaping () -> Void) -> ParentBuilder {
        mocker.addAction(action, for: setMember)
        return .init(mocker: mocker)
    }
}
