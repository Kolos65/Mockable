//
//  AttributeSyntax+Extensions.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 25..
//

import SwiftSyntax

extension AttributeSyntax {
    static var escaping: Self {
        AttributeSyntax(
            atSign: .atSignToken(),
            attributeName: IdentifierTypeSyntax(
                name: .keyword(.escaping)
            )
        )
    }
}
