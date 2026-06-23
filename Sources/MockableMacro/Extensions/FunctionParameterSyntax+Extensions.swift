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

        let baseType: TypeSyntax
        if role == .parameter {
            baseType = type
        } else if let attributeType = type.as(AttributedTypeSyntax.self) {
            baseType = TypeSyntax(attributeType.baseType)
        } else {
            baseType = TypeSyntax(type)
        }

        // Implicitly unwrapped optionals (`T!`) are only valid in a narrow set of
        // declaration positions. Once we embed the type inside a generic argument
        // (e.g. `Parameter<T!>`) or a closure type (e.g. `(T!) -> Void`), it
        // becomes invalid Swift. Rewrite to a regular Optional in those cases.
        if let iuo = baseType.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return TypeSyntax(OptionalTypeSyntax(wrappedType: iuo.wrappedType))
        }
        return baseType
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
