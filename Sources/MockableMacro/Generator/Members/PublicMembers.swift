//
//  PublicMembers.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 16..
//

import SwiftSyntax

struct PublicMembers {

    // MARK: Private Properties

    private let protocolDeclaration: ProtocolDeclSyntax

    // MARK: Init

    init(_ protocolDeclaration: ProtocolDeclSyntax) {
        self.protocolDeclaration = protocolDeclaration
    }

    // MARK: Properties

    var given: MemberBlockItemSyntax {
        let declaration = DeclSyntax(
            stringLiteral: """
            @available(*, deprecated, message: "Use given(_ service:) of MockableTest instead.")
            \(modifier)func given() -> ReturnBuilder { .init(mocker: mocker) }
            """
        )
        return .init(decl: declaration)
    }
    var when: MemberBlockItemSyntax {
        let declaration = DeclSyntax(
            stringLiteral: """
            @available(*, deprecated, message: "Use when(_ service:) of MockableTest instead.")
            \(modifier)func when() -> ActionBuilder { .init(mocker: mocker) }
            """
        )
        return .init(decl: declaration)
    }
    var verify: MemberBlockItemSyntax {
        let declaration = DeclSyntax(
            stringLiteral: """
            @available(*, deprecated, message: "Use verify(_ service:) of MockableTest instead.")
            \(modifier)func verify(with assertion: @escaping MockableAssertion) -> VerifyBuilder {
                .init(mocker: mocker, assertion: assertion)
            }
            """
        )
        return .init(decl: declaration)
    }
    var reset: MemberBlockItemSyntax {
        let declaration = DeclSyntax(
            stringLiteral: """
            \(modifier)func reset(_ scopes: Set<\(Constants.scopeEnumName)> = .all) { mocker.reset(scopes: scopes) }
            """
        )
        return .init(decl: declaration)
    }
}

// MARK: - Helpers

extension PublicMembers {
    private var modifier: String {
        guard !protocolDeclaration.modifiers.isEmpty else { return "" }
        return "\(protocolDeclaration.modifiers.trimmedDescription) "
    }
}
