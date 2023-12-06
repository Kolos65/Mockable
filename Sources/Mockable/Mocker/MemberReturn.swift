//
//  MemberReturn.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

/// A class representing the return value associated with a member.
///
/// `MemberReturn` associates a member of type `Member` with a `ReturnValue` object,
/// encapsulating the information about the expected return value or behavior.
public class MemberReturn<Member> {
    /// The member associated with the return value.
    public let member: Member

    /// The `ReturnValue` object encapsulating information about the expected return value or behavior.
    public let returnValue: ReturnValue

    /// Initializes a new instance of `MemberReturn`.
    ///
    /// - Parameters:
    ///   - member: The member to associate with the return value.
    ///   - returnValue: The `ReturnValue` object representing the expected return value or behavior.
    public init(member: Member, returnValue: ReturnValue) {
        self.member = member
        self.returnValue = returnValue
    }
}
