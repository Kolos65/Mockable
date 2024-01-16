//
//  MockableMacro.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

import SwiftSyntax
import SwiftSyntaxMacros

public enum MockableMacro: PeerMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw MockableMacroError.notAProtocol
        }

        let requirements = try Requirements(protocolDecl)
        let declaration = try MockFacotry.build(from: requirements)
        let codeblock = CodeBlockItemListSyntax {
            CodeBlockItemSyntax(item: .decl(declaration))
        }

        let ifClause = IfConfigClauseListSyntax {
            IfConfigClauseSyntax(
                poundKeyword: .poundIfToken(),
                condition: DeclReferenceExprSyntax(baseName: NS.MOCKING),
                elements: .statements(codeblock)
            )
        }

        return [IfConfigDeclSyntax(clauses: ifClause).cast(DeclSyntax.self)]
    }
}
