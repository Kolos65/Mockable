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
        guard let declaration = declaration.as(ProtocolDeclSyntax.self) else {
            throw MockableMacroError.notAProtocol
        }

        let classDefinition = ClassDeclaration(declaration)
        let privateMembers = PrivateMembers(declaration)
        let publicMembers = PublicMembers(declaration)
        let members = try MemberDeclarations(declaration)
        let memberEnum = MemberEnum(declaration, members)
        let inits = InitConformances(declaration, members.inits)
        let functions = FunctionConformances(declaration, members.functions)
        let variables = VariableConformances(declaration, members.variables)
        let builderStructs = BuilderStructs(declaration, members.variables, members.functions)

        let classDeclaration = ClassDeclSyntax(
            leadingTrivia: classDefinition.leadingTrivia,
            modifiers: classDefinition.modifiers,
            name: classDefinition.name,
            genericParameterClause: classDefinition.genericParameterClause,
            inheritanceClause: classDefinition.inheritanceClause,
            genericWhereClause: classDefinition.genericWhereClause,
            memberBlock: try .init {
                privateMembers.mocker
                publicMembers.given
                publicMembers.when
                publicMembers.verify
                publicMembers.reset
                for initializer in inits.members {
                    initializer
                }
                for function in try functions.members {
                    function
                }
                for variable in try variables.members {
                    variable
                }
                try memberEnum.memberBlockItem
                try builderStructs.givenBuilder
                try builderStructs.actionBuilder
                try builderStructs.verifyBuilder
            },
            trailingTrivia: classDefinition.trailingTrivia
        )

        return [DeclSyntax(classDeclaration)]
    }
}
