//
//  MemberAction.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

/// A class representing an action to be performed on a member.
///
/// `MemberAction` associates a member of type `Member` with a closure (`action`)
/// that can be executed when needed.
public class MemberAction<Member> {
    /// The member associated with the action.
    public let member: Member

    /// The closure representing the action to be performed.
    public let action: () -> Void

    /// Initializes a new instance of `MemberAction`.
    ///
    /// - Parameters:
    ///   - member: The member to associate with the action.
    ///   - action: The closure representing the action to be performed.
    public init(member: Member, action: @escaping () -> Void) {
        self.member = member
        self.action = action
    }
}
