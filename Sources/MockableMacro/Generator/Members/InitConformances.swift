//
//  InitConformances.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 23..
//

import SwiftSyntax
import SwiftSyntaxMacros

struct InitConformances {

    // MARK: Private Properties

    private let protocolDeclaration: ProtocolDeclSyntax
    private let inits: [InitializerDeclSyntax]

    // MARK: Init

    init(_ protocolDeclaration: ProtocolDeclSyntax, _ inits: [InitializerDeclSyntax]) {
        self.protocolDeclaration = protocolDeclaration
        self.inits = inits
    }

    // MARK: Properties

    var members: [MemberBlockItemSyntax] {
        let initConformances: [MemberBlockItemSyntax] = inits.map {
            var attributes = $0.attributes.trimmed
            attributes.trailingTrivia = .newline
            let decl = InitializerDeclSyntax(
                attributes: attributes,
                modifiers: protocolDeclaration.modifiers,
                initKeyword: $0.initKeyword.trimmed,
                optionalMark: $0.optionalMark?.trimmed,
                genericParameterClause: $0.genericParameterClause?.trimmed,
                signature: $0.signature.trimmed,
                genericWhereClause: $0.genericWhereClause?.trimmed,
                body: .init(statements: [])
            )
            return .init(decl: decl)
        }
        let hasDefault = inits.contains {
            $0.signature.effectSpecifiers == nil
            && $0.signature.parameterClause.parameters.isEmpty
            && $0.optionalMark == nil
            && $0.genericWhereClause == nil
            && $0.genericParameterClause == nil
        }
        guard hasDefault else {
            let defaultInit = InitializerDeclSyntax(
                modifiers: protocolDeclaration.modifiers,
                signature: .init(parameterClause: .init(parameters: [])),
                body: .init(statements: [])
            )
            return initConformances + [.init(decl: defaultInit)]
        }
        return initConformances
    }
}
