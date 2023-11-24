//
//  PrivateMembers.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 16..
//

import SwiftSyntax
import SwiftSyntaxMacros

struct PrivateMembers {

    // MARK: Private Properties

    private let protocolDeclaration: ProtocolDeclSyntax

    // MARK: Init

    init(_ protocolDeclaration: ProtocolDeclSyntax) {
        self.protocolDeclaration = protocolDeclaration
    }

    // MARK: Properties

    var mocker: MemberBlockItemSyntax {
        let name = protocolDeclaration.name.trimmedDescription
        let declaration = DeclSyntax(
            stringLiteral: "private var mocker = Mocker<\(Constants.implementationPrefix)\(name)>()"
        )
        return .init(decl: declaration)
    }
}
