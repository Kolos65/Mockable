//
//  Initializer+Mockable.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

// MARK: - InitializerRequirement + Mockable

extension InitializerRequirement: Mockable {
    func implement(with modifiers: DeclModifierListSyntax) throws -> DeclSyntax {
        return InitializerDeclSyntax(
            attributes: syntax.attributes.trimmed.with(\.trailingTrivia, .newline),
            modifiers: modifiers,
            initKeyword: syntax.initKeyword.trimmed,
            optionalMark: syntax.optionalMark?.trimmed,
            genericParameterClause: syntax.genericParameterClause?.trimmed,
            signature: syntax.signature.trimmed,
            genericWhereClause: syntax.genericWhereClause?.trimmed,
            body: .init(statements: [])
        )
        .cast(DeclSyntax.self)
    }
}
