//
//  MemberDeclarations.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 11. 18..
//

import SwiftSyntax

struct MemberDeclarations {

    // MARK: Properties

    var variables = [VariableDeclaration]()
    var functions = [FunctionDeclaration]()
    var inits = [InitializerDeclSyntax]()

    // MARK: Init

    init(_ protocolDeclaration: ProtocolDeclSyntax) throws {
        let members = protocolDeclaration.memberBlock.members
        self.variables = try members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter {
                guard !$0.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) }) else {
                    throw MockableMacroError.staticMembersNotSupported
                }
                return true
            }
            .enumerated()
            .map(VariableDeclaration.init)

        self.functions = try members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .filter {
                guard !$0.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) }) else {
                    throw MockableMacroError.staticMembersNotSupported
                }
                guard case .identifier = $0.name.tokenKind else {
                    throw MockableMacroError.operatorsNotSupported
                }
                return true
            }
            .enumerated()
            .map { index, element in
                FunctionDeclaration(index: variables.count + index, syntax: element)
            }

        self.inits = members.compactMap { $0.decl.as(InitializerDeclSyntax.self) }

        guard members.compactMap({ $0.decl.as(SubscriptDeclSyntax.self) }).isEmpty else {
            throw MockableMacroError.subscriptsNotSupported
        }
    }
}
