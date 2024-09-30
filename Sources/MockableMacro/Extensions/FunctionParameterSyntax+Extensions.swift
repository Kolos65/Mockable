//
//  FunctionParameterSyntax+Extensions.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 11. 20..
//

import SwiftSyntax
import SwiftSyntaxMacros

enum FunctionParameterTypeResolveRole {
    /// Resolves a type that can be used for property type bindings, removes attributes.
    case binding
    /// Resolves a type that can be used as a function or closure parameter, keeps attributes.
    case parameter
}

extension FunctionParameterSyntax {
    func resolvedType(for role: FunctionParameterTypeResolveRole = .binding) -> TypeSyntax {
        guard ellipsis == nil else {
            return TypeSyntax(ArrayTypeSyntax(element: type))
        }

        guard role != .parameter else { return type }

        if let attributeType = type.as(AttributedTypeSyntax.self) {
            return TypeSyntax(attributeType.baseType)
        } else {
            return TypeSyntax(type)
        }
    }

    var isInout: Bool {
        #if canImport(SwiftSyntax600)
        type.as(AttributedTypeSyntax.self)?.specifiers.contains { specifier in
            guard case .simpleTypeSpecifier(let simpleSpecifier) = specifier else { return false }
            return simpleSpecifier.specifier.tokenKind == .keyword(.inout)
        } ?? false
        #else
        type.as(AttributedTypeSyntax.self)?.specifier?.tokenKind == .keyword(.inout)
        #endif
    }
}
