//
//  MockableMacro.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum MockableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw MockableMacroError.notAProtocol
        }

        #if swift(>=6) && !canImport(SwiftSyntax600)
        context.diagnose(Diagnostic(node: node, message: MockableMacroWarning.versionMismatch))
        #endif

        let requirements = try Requirements(protocolDecl)
        let declaration = try MockFactory.build(from: requirements)
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

        return [DeclSyntax(IfConfigDeclSyntax(clauses: ifClause))]
    }
}
