//
//  Requirements.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 12..
//

import SwiftSyntax

struct Requirements {

    // MARK: Properties

    let syntax: ProtocolDeclSyntax
    let modifiers: DeclModifierListSyntax
    var functions = [FunctionRequirement]()
    var variables = [VariableRequirement]()
    var initializers = [InitializerRequirement]()

    // MARK: Init

    init(_ syntax: ProtocolDeclSyntax) throws {
        self.syntax = syntax
        let members = syntax.memberBlock.members

        guard members.compactMap({ $0.decl.as(SubscriptDeclSyntax.self) }).isEmpty else {
            throw MockableMacroError.subscriptsNotSupported
        }
        self.modifiers = syntax.modifiers.trimmed.filter { modifier in
            guard case .keyword(let keyword) = modifier.name.tokenKind else {
                return true
            }
            return keyword != .private
        }

        self.variables = try members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter {
                guard !$0.modifiers.contains(where: isStatic) else {
                    throw MockableMacroError.staticMembersNotSupported
                }
                return true
            }
            .enumerated()
            .map(VariableRequirement.init)

        self.functions = try members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .filter {
                guard !$0.modifiers.contains(where: isStatic) else {
                    throw MockableMacroError.staticMembersNotSupported
                }
                guard case .identifier = $0.name.tokenKind else {
                    throw MockableMacroError.operatorsNotSupported
                }
                return true
            }
            .enumerated()
            .map { index, element in
                FunctionRequirement(index: variables.count + index, syntax: element)
            }

        self.initializers = members
            .compactMap { $0.decl.as(InitializerDeclSyntax.self) }
            .enumerated()
            .map { InitializerRequirement(index: $0, syntax: $1) }
    }
}

// MARK: - Helpers

extension Requirements {
    private func isStatic(_ modifier: DeclModifierSyntax) -> Bool {
        modifier.name.tokenKind == .keyword(.static)
    }
}
