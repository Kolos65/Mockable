//
//  ProtocolDeclSyntax+Extensions.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

extension ProtocolDeclSyntax {
    var mockName: String {
        NS.Mock.trimmedDescription + name.trimmedDescription
    }

    var mockType: IdentifierTypeSyntax {
        IdentifierTypeSyntax(name: .identifier(mockName))
    }
}
