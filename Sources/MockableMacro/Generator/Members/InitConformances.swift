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
            var decl = $0
            decl.leadingTrivia = ""
            decl.modifiers = protocolDeclaration.modifiers
            decl.body = .init(statements: [])
            decl.trailingTrivia = ""
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
