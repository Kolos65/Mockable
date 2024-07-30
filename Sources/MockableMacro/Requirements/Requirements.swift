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
    let isActor: Bool
    let containsGenericExistentials: Bool
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

        self.modifiers = Self.initModifiers(syntax)
        self.isActor = Self.initIsActor(syntax)
        self.initializers = Self.initInitializers(members)
        self.variables = try Self.initVariables(members)
        self.functions = try Self.initFunctions(members, startIndex: variables.count)
        self.containsGenericExistentials = try Self.initContainsGenericExistentials(variables, functions)
    }
}

// MARK: - Helpers

extension Requirements {
    private static func isStatic(_ modifier: DeclModifierSyntax) -> Bool {
        modifier.name.tokenKind == .keyword(.static)
    }

    private static func initModifiers(_ syntax: ProtocolDeclSyntax) -> DeclModifierListSyntax {
        syntax.modifiers.trimmed.filter { modifier in
            guard case .keyword(let keyword) = modifier.name.tokenKind else {
                return true
            }
            return keyword != .private
        }
    }

    private static func initIsActor(_ syntax: ProtocolDeclSyntax) -> Bool {
        guard let inheritanceClause = syntax.inheritanceClause,
              !inheritanceClause.inheritedTypes.isEmpty else {
            return false
        }

        for inheritedType in inheritanceClause.inheritedTypes {
            if let type = inheritedType.type.as(IdentifierTypeSyntax.self),
               type.name.trimmed.tokenKind == NS.Actor.tokenKind {
                return true
            }
        }

        return false
    }

    private static func initVariables(_ members: MemberBlockItemListSyntax) throws -> [VariableRequirement] {
        try members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter {
                guard !$0.modifiers.contains(where: isStatic) else {
                    throw MockableMacroError.staticMembersNotSupported
                }
                return true
            }
            .enumerated()
            .map(VariableRequirement.init)
    }

    private static func initFunctions(_ members: MemberBlockItemListSyntax,
                                      startIndex: Int) throws -> [FunctionRequirement] {
        try members
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
                FunctionRequirement(index: startIndex + index, syntax: element)
            }
    }

    private static func initInitializers(_ members: MemberBlockItemListSyntax) -> [InitializerRequirement] {
        members
            .compactMap { $0.decl.as(InitializerDeclSyntax.self) }
            .enumerated()
            .map { InitializerRequirement(index: $0, syntax: $1) }
    }

    private static func initContainsGenericExistentials(
        _ variables: [VariableRequirement],
        _ functions: [FunctionRequirement]
    ) throws -> Bool {
        let variables = try variables.filter {
            let type = try $0.syntax.type
            return hasParametrizedProtocolRequirement(type)
        }

        let functions = functions.filter {
            guard let returnClause = $0.syntax.signature.returnClause else { return false }
            let type = returnClause.type
            return hasParametrizedProtocolRequirement(type)
        }

        return !variables.isEmpty || !functions.isEmpty
    }

    private static func hasParametrizedProtocolRequirement(_ type: TypeSyntax) -> Bool {
        if let type = type.as(SomeOrAnyTypeSyntax.self),
           type.someOrAnySpecifier.tokenKind == .keyword(.any),
           let type = type.constraint.as(IdentifierTypeSyntax.self),
           let argumentClause = type.genericArgumentClause,
           !argumentClause.arguments.isEmpty {
            return true
        } else if let type = type.as(IdentifierTypeSyntax.self),
                  let argumentClause = type.genericArgumentClause {
            return argumentClause.arguments.contains {
                return hasParametrizedProtocolRequirement($0.argument)
            }
        } else {
            return false
        }
    }
}
